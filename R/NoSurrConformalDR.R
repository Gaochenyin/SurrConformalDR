#' No Surrogate-assisted Conformal Inference for Efficient Individual Causal Effect
#' Estimation
#'
#' See details in [SurrConformalDR::SurrConformalDR()].
#'
#' @export
NoSurrConformalDR <- function(df,
                              train.idx, eval.idx,
                              outcome.type = c("Continuous", "Categorical"), # Categorical
                              SL.library = c("SL.glm"),
                              alphaCI = 0.05,
                              nested = TRUE){
  # outcome can be Continuous or Categorical
  # begin estimation
  N <- nrow(df)
  outcome.type <- match.arg(outcome.type)
  ## -------------------
  # create non-conformity score
  if(outcome.type == 'Continuous'){

    # CQR by quantile regression function
    # without surrogates
    qrf.Y1.obj <- grf::quantile_forest(X = df[train.idx,] %>% filter(A == 1 &
                                                                       D == 1) %>%
                                         dplyr::select(grep('^([X])',
                                                            colnames(df),
                                                            value = TRUE)),
                                       Y = df[train.idx, ] %>% filter(A == 1 &
                                                                        D == 1) %>%
                                         pull(Y),
                                       quantiles = c(alphaCI/2, 1-alphaCI/2))

    qrf.Y0.obj <- grf::quantile_forest(X = df[train.idx,] %>% filter(A == 0 &
                                                                       D == 1) %>%
                                         dplyr::select(grep('^([X])',
                                                            colnames(df),
                                                            value = TRUE)),
                                       Y = df[train.idx, ] %>% filter(A == 0 &
                                                                        D == 1) %>%
                                         pull(Y),
                                       quantiles = c(alphaCI/2, 1-alphaCI/2))

    q.Y1 <- predict(qrf.Y1.obj, df[, grep('([X])', colnames(df),
                                          value = TRUE),
                                   drop = FALSE])$predictions
    q.Y0 <- predict(qrf.Y0.obj, df[, grep('([X])', colnames(df),
                                          value = TRUE),
                                   drop = FALSE])$predictions

    df$R.woS <- with(df, pmax(q.Y1[, 1] - Y, Y - q.Y1[, 2]) * A) +
      with(df, pmax(q.Y0[, 1] - Y, Y - q.Y0[, 2]) * (1 - A))

  }

  if(outcome.type == 'Categorical'){
    # woS
    objY1.X <- multinom(paste('Y~', paste(grep('^([X])',
                                               colnames(df),
                                               value = TRUE), collapse = '+')),
                        data = df[train.idx,],
                        subset = A == 1 & D == 1, trace = FALSE)
    probY1.X <- predict(objY1.X, newdata = df[, grep('^([X])',
                                                     colnames(df),
                                                     value = TRUE),
                                              drop = FALSE],
                        type = 'probs')

    objY0.X <- multinom(paste('Y~', paste(grep('^([X])',
                                               colnames(df),
                                               value = TRUE), collapse = '+')),
                        data = df[train.idx,],
                        subset = A == 0 & D == 1, trace = FALSE)
    probY0.X <- predict(objY0.X, newdata = df[, grep('^([X])',
                                                     colnames(df),
                                                     value = TRUE),
                                              drop = FALSE],
                        type = 'probs')

    # check the dimension of probability for missing factor level
    if(ncol(probY1.X) < length(unique(df$Y))){
      level.prob <- colnames(probY1.X)
      level.NA <- setdiff(unique(df$Y),
                          as.numeric(level.prob))
      probY1.X <- cbind(probY1.X,
                        matrix(0, nrow = nrow(probY1.X),
                               ncol = length(level.NA)))
      colnames(probY1.X) <- c(level.prob, level.NA)
    }

    if(ncol(probY0.X) < length(unique(df$Y))){
      level.prob <- colnames(probY0.X)
      level.NA <- setdiff(unique(df$Y),
                          as.numeric(level.prob))
      probY0.X <- cbind(probY0.X,
                        matrix(0, nrow = nrow(probY0.X),
                               ncol = length(level.NA)))
      colnames(probY0.X) <- c(level.prob, level.NA)
    }


    # compute the non-conformity score of each outcomes
    R.XY1Mat.X <- apply(probY1.X, 1, function(x){
      1 - cumsum(sort(x))[rank(x)]}) %>% t()
    R.XY0Mat.X <- apply(probY0.X, 1, function(x){
      1 - cumsum(sort(x))[rank(x)]}) %>% t()


    # choose the observed one based on the outcomes
    df$R.woS <- with(df, mapply(function(row_index, col_index) R.XY1Mat.X[row_index, col_index],
                                row_index = 1:nrow(R.XY1Mat.X),
                                col_index = match(df$Y,
                                                  as.numeric(colnames(probY1.X)))) * A) +
      with(df, mapply(function(row_index, col_index) R.XY0Mat.X[row_index, col_index],
                      row_index = 1:nrow(R.XY0Mat.X),
                      col_index = match(df$Y,
                                        as.numeric(colnames(probY0.X))))* (1 - A))
  }

  # -------------------------
  # model fitting for nuisance functions
  df.train <- df[train.idx, ]
  df.eval <- df[eval.idx, ]

  model.obj.woS <- list()

  # model training for D|X, A
  psD.obj <- model.obj.woS$psD.obj <-
    SuperLearner(Y = df.train$D,
                 X = df.train[, grep('([XA])',
                                     colnames(df.train), value = TRUE),
                              drop = FALSE],
                 SL.library = SL.library,
                 family = binomial())
  # model for A|X
  psA.obj <- model.obj.woS$psA.obj <-
    SuperLearner(Y = as.numeric(df.train$A),
                 X = df.train[,  grep('([X])',
                                      colnames(df.train), value = TRUE),
                              drop = FALSE],
                 SL.library = SL.library,
                 family = binomial())


  ## further split df.train into two folds, I_11 and I_12
  ## one for computing the initial estimate,
  ## the other one is for training the outcome model
  folds.train.idx <- caret::createFolds(1:length(train.idx), k = 2)
  train1.idx <- folds.train.idx[[1]]
  train2.idx <- folds.train.idx[[2]]
  df.train1 <- df.train[train1.idx, ]
  df.train2 <- df.train[train2.idx, ]

  # initial estimate for theta by IPW (with first split data I_11)
  thetaA1.init <- initialize.theta(df.train1, psA.obj, psD.obj,
                                   target.A = 1, alphaCI = alphaCI)
  thetaA0.init <- initialize.theta(df.train1, psA.obj, psD.obj,
                                   target.A = 0, alphaCI = alphaCI)
  # fit the model on the second split data I_12
  ## model training without S
  model.obj.woS$mA1.obj.r <- SuperLearner(Y = as.numeric(df.train2$R.woS <= thetaA1.init)[df.train2$D==1],
                                          X = df.train2[df.train2$D==1,  grep('^([XD])',
                                                                              colnames(df.train2),
                                                                              value = TRUE),
                                                        drop = FALSE],
                                          SL.library = SL.library,
                                          family = binomial())
  model.obj.woS$mA0.obj.r <- SuperLearner(Y = as.numeric(df.train2$R.woS <= thetaA0.init)[df.train2$D==1],
                                          X = df.train2[df.train2$D==1,  grep('^([XD])',
                                                                              colnames(df.train2),
                                                                              value = TRUE),
                                                        drop = FALSE],
                                          SL.library = SL.library,
                                          family = binomial())


  ## construct the estimated cutoff values for the observed outcomes
  ## EIF-based without surrogates
  cutoff.Y1.woS_obs <- tryCatch(uniroot(f = function(theta)eif_theta(theta,
                                                                     df.eval = df.eval,
                                                                     model.obj = model.obj.woS,
                                                                     target.A = 1, wS = FALSE,
                                                                     alphaCI = alphaCI,
                                                                     counterfactual = FALSE),
                                        interval = quantile(df.eval$R.woS, c(0.01, 0.99),
                                                            na.rm = TRUE),
                                        extendInt = 'yes',
                                        maxiter = 100)$root,
                                error = function(e) quantile(df.eval$R.woS, 1 - alphaCI,
                                                             na.rm = TRUE))

  cutoff.Y0.woS_obs <- tryCatch(uniroot(f = function(theta)eif_theta(theta,
                                                                     df.eval = df.eval,
                                                                     model.obj = model.obj.woS,
                                                                     target.A = 0, wS = FALSE,
                                                                     alphaCI = alphaCI,
                                                                     counterfactual = FALSE),
                                        interval = quantile(df.eval$R.woS, c(0.01, 0.99),
                                                            na.rm = TRUE),
                                        extendInt = 'yes',
                                        maxiter = 100)$root,
                                error = function(e) quantile(df.eval$R.woS, 1 - alphaCI,
                                                             na.rm = TRUE))


  ## construct the prediction sets
  if(outcome.type == 'Continuous'){
    # conformal inference on the observed outcomes
    ## woS
    lower.Y1_A1.woS <- predict(qrf.Y1.obj,
                               newdata = df.eval[, grep('^([X])',
                                                        colnames(df.eval),
                                                        value = TRUE),
                                                 drop = FALSE])$predictions[, 1] -
      cutoff.Y1.woS_obs
    upper.Y1_A1.woS <- predict(qrf.Y1.obj,
                               newdata = df.eval[, grep('^([X])',
                                                        colnames(df.eval),
                                                        value = TRUE),
                                                 drop = FALSE])$predictions[, 2] +
      cutoff.Y1.woS_obs



    # CQR
    lower.Y0_A0.woS <- predict(qrf.Y0.obj,
                               newdata = df.eval[, grep('^([X])',
                                                        colnames(df.eval),
                                                        value = TRUE),
                                                 drop = FALSE])$predictions[, 1] -
      cutoff.Y0.woS_obs
    upper.Y0_A0.woS <- predict(qrf.Y0.obj,
                               newdata = df.eval[, grep('^([X])',
                                                        colnames(df.eval),
                                                        value = TRUE),
                                                 drop = FALSE])$predictions[, 2] +
      cutoff.Y0.woS_obs

    ## for ITE
    ## EIF-based without surrogates
    cutoff.Y1.woS <- tryCatch(uniroot(f = function(theta)eif_theta(theta,
                                                                   df.eval = df.eval,
                                                                   model.obj = model.obj.woS,
                                                                   target.A = 1, wS = FALSE,
                                                                   alphaCI = alphaCI),
                                      interval = quantile(df.eval$R.woS, c(0.01, 0.99),
                                                          na.rm = TRUE),
                                      extendInt = 'yes',
                                      maxiter = 100)$root,
                              error = function(e) quantile(df.eval$R.woS, 1 - alphaCI,
                                                           na.rm = TRUE))

    cutoff.Y0.woS <- tryCatch(uniroot(f = function(theta)eif_theta(theta,
                                                                   df.eval = df.eval,
                                                                   model.obj = model.obj.woS,
                                                                   target.A = 0, wS = FALSE,
                                                                   alphaCI = alphaCI),
                                      interval = quantile(df.eval$R.woS, c(0.01, 0.99),
                                                          na.rm = TRUE),
                                      extendInt = 'yes',
                                      maxiter = 100)$root,
                              error = function(e) quantile(df.eval$R.woS, 1 - alphaCI,
                                                           na.rm = TRUE))

    ## woS
    lower.Y1_A0.woS <- predict(qrf.Y1.obj,
                               newdata = df.eval[, grep('^([X])',
                                                        colnames(df.eval),
                                                        value = TRUE),
                                                 drop = FALSE])$predictions[, 1] -
      cutoff.Y1.woS
    upper.Y1_A0.woS <- predict(qrf.Y1.obj,
                               newdata = df.eval[, grep('^([X])',
                                                        colnames(df.eval),
                                                        value = TRUE),
                                                 drop = FALSE])$predictions[, 2] +
      cutoff.Y1.woS

    lower.Y0_A1.woS <- predict(qrf.Y0.obj,
                               newdata = df.eval[, grep('^([X])',
                                                        colnames(df.eval),
                                                        value = TRUE),
                                                 drop = FALSE])$predictions[, 1] -
      cutoff.Y0.woS
    upper.Y0_A1.woS <- predict(qrf.Y0.obj,
                               newdata = df.eval[, grep('^([X])',
                                                        colnames(df.eval),
                                                        value = TRUE),
                                                 drop = FALSE])$predictions[, 2] +
      cutoff.Y0.woS

    # inference on the observed outcomes
    lower.Y.woS <- lower.Y1_A1.woS * (df.eval$A == 1) +
      lower.Y0_A0.woS * (df.eval$A == 0)
    upper.Y.woS <- upper.Y1_A1.woS * (df.eval$A == 1) +
      upper.Y0_A0.woS * (df.eval$A == 0)

    # inference on tau
    lower.tau.woS <- (lower.Y1_A0.woS - (df.eval$Y)) * (df.eval$A == 0) +
      ((df.eval$Y) - upper.Y0_A1.woS) * (df.eval$A == 1)
    upper.tau.woS <- (upper.Y1_A0.woS - (df.eval$Y)) * (df.eval$A == 0) +
      ((df.eval$Y) - lower.Y0_A1.woS) * (df.eval$A == 1)

    # organize the results
    df.eval <- cbind(df.eval,

                     lower.Y = lower.Y.woS,
                     upper.Y = upper.Y.woS,

                     lower.tau = lower.tau.woS,
                     upper.tau = upper.tau.woS)
    if(nested){
      # nested conformal inference for the target data where primary outcome is missing
      CI.D0.woS <- conformalIntSplitD0(cbind(df.eval,
                                             lower = lower.tau.woS,
                                             upper = upper.tau.woS)[df.eval$D==1, ],
                                       df.eval[df.eval$D==0, ],
                                       wS = FALSE)
      df.eval$lower.tau[df.eval$D==0] <- CI.D0.woS$lower
      df.eval$upper.tau[df.eval$D==0] <- CI.D0.woS$upper
    }

  }
  if(outcome.type == 'Categorical'){
    # for A = 0, Y1
    Y1predSet.A1woS <- apply(R.XY1Mat.X, 1, function(x){
      level.Y <- colnames(probY1.XS)[order(x)]
      level.Y[which(x[order(x)] <= cutoff.Y1.woS_obs)]
    }, simplify = FALSE)[eval.idx]

    # for A = 1, Y0
    Y0predSet.A0woS <- apply(R.XY0Mat.X, 1, function(x){
      level.Y <- colnames(probY0.XS)[order(x)]
      level.Y[which(x[order(x)] <= cutoff.Y0.woS_obs)]
    }, simplify = FALSE)[eval.idx]

    # organize the output for the evaluation sets
    ## for the observed one
    ## without surrogates
    df.eval$sets_observed.woS <- Y0predSet.A0woS
    df.eval$sets_observed.woS[df.eval$A==1] <-
      Y1predSet.A1woS[df.eval$A==1]
  }

  # return the evaluation df without non-conformal scores
  return(df.eval %>% dplyr::select(-R.woS))

}

