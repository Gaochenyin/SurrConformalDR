#' Surrogate-assisted Conformal Inference for Efficient Individual Causal Effect
#' Estimation
#'
#' @param df data frame contains
#' * X.1, X.2, ...: covariates
#' * D: data origin indicator, a binary vector
#' with 1 being the source data and 0 being the target data
#' * A treatment indicator, a binary vector
#' * S.1, S.2, ...: surrogates
#' * Y: observed primary outcomes
#' @param train.idx index of `df` for model training
#' @param eval.idx index of `df` for evaluating conformal inference
#' @param outcome.type the type of primary outcomes.
#' @param SL.library Either a character vector of prediction algorithms
#' or a list containing character vectors. See details in [SuperLearner::SuperLearner()].
#' The default is `SL.glm`
#' @param alphaCI confidence level. The default is 0.05.
#' @param nested Logical. Should nested conformal inference be performed
#' when the primary outcomes are missing. Used only when \code{outcome.type = "Continuous"}.
#' The default is TRUE.
#'
#' @return
#' when \code{outcome.type = "Continuous"}:
#' * lower.Y, upper Y: prediction regions for the observed outcomes
#' with index `eval.idx`
#' * lower.tau, upper.tau: prediction regions for the individualized treatment effects
#' with index `eval.idx`
#'
#' when \code{outcome.type = "Categorical"}:
#' * sets_observed: prediction sets for the observed outcomes
#' with index `eval.idx`
#' @export
SurrConformalDR <- function(df,
                            train.idx, eval.idx,
                            outcome.type = c("Continuous", "Categorical"), # Categorical
                            SL.library = c("SL.glm"),
                            alphaCI = 0.05,
                            nested = TRUE) {
  # begin estimation
  N <- nrow(df)
  outcome.type <- match.arg(outcome.type)
  ## -------------------
  # create non-conformity score
  if (outcome.type == "Continuous") {
    # CQR by quantile regression function
    qrf.Y1.obj <- grf::quantile_forest(
      X = df[train.idx, ] %>% filter(A == 1 &
        D == 1) %>%
        dplyr::select(grep("^([XS])",
          colnames(df),
          value = TRUE
        )),
      Y = df[train.idx, ] %>% filter(A == 1 &
        D == 1) %>%
        pull(Y),
      quantiles = c(alphaCI / 2, 1 - alphaCI / 2)
    )

    # change for SuperLearner model
    df_train_A1 <- data.frame(
      tau = predict(qrf.Y1.obj,
        newdata = df[train.idx, grep("^([XS])",
          colnames(df),
          value = TRUE
        )]
      )$predictions,
      df[train.idx, grep("^([XA])",
        colnames(df),
        value = TRUE
      )]
    ) %>%
      filter(A == 1) %>%
      dplyr::select(-A)

    m.X1q1.obj <- SuperLearner(
      Y = df_train_A1$tau.1,
      X = df_train_A1[, grep("([X])",
        colnames(df_train_A1),
        value = TRUE
      ),
      drop = FALSE
      ],
      SL.library = SL.library
    )



    m.X1q2.obj <- SuperLearner(
      Y = df_train_A1$tau.2,
      X = df_train_A1[, grep("([X])",
        colnames(df_train_A1),
        value = TRUE
      ),
      drop = FALSE
      ],
      SL.library = SL.library
    )


    q.Y1 <- cbind(
      predict(m.X1q1.obj, newdata = df[, grep("([X])", colnames(df),
        value = TRUE
      ),
      drop = FALSE
      ])$pred,
      predict(m.X1q2.obj, newdata = df[, grep("([X])", colnames(df),
        value = TRUE
      ),
      drop = FALSE
      ])$pred
    )

    qrf.Y0.obj <- grf::quantile_forest(
      X = df[train.idx, ] %>% filter(A == 0 &
        D == 1) %>%
        dplyr::select(grep("^([XS])",
          colnames(df),
          value = TRUE
        )),
      Y = df[train.idx, ] %>% filter(A == 0 &
        D == 1) %>%
        pull(Y),
      quantiles = c(alphaCI / 2, 1 - alphaCI / 2)
    )

    # change for SuperLearner model
    df_train_A0 <- data.frame(
      tau = predict(qrf.Y0.obj,
        newdata = df[train.idx, grep("^([XS])",
          colnames(df),
          value = TRUE
        )]
      )$predictions,
      df[train.idx, grep("^([XA])",
        colnames(df),
        value = TRUE
      )]
    ) %>%
      filter(A == 0) %>%
      dplyr::select(-A)

    m.X0q1.obj <- SuperLearner(
      Y = df_train_A0$tau.1,
      X = df_train_A0[, grep("([X])",
        colnames(df_train_A0),
        value = TRUE
      ),
      drop = FALSE
      ],
      SL.library = SL.library
    )



    m.X0q2.obj <- SuperLearner(
      Y = df_train_A0$tau.2,
      X = df_train_A0[, grep("([X])",
        colnames(df_train_A0),
        value = TRUE
      ),
      drop = FALSE
      ],
      SL.library = SL.library
    )

    q.Y0 <- cbind(
      predict(m.X0q1.obj, newdata = df[, grep("([X])", colnames(df),
        value = TRUE
      ),
      drop = FALSE
      ])$pred,
      predict(m.X0q2.obj, newdata = df[, grep("([X])", colnames(df),
        value = TRUE
      ),
      drop = FALSE
      ])$pred
    )

    df$R.wS <- with(df, pmax(q.Y1[, 1] - Y, Y - q.Y1[, 2]) * A) +
      with(df, pmax(q.Y0[, 1] - Y, Y - q.Y0[, 2]) * (1 - A))
  }

  if (outcome.type == "Categorical") {
    # wS
    objY1.XS <- nnet::multinom(
      paste("Y~", paste(grep("^([XS])",
        colnames(df),
        value = TRUE
      ), collapse = "+")),
      data = df[train.idx, ],
      subset = A == 1 & D == 1, trace = FALSE
    )
    probY1.XS <- predict(objY1.XS,
      newdata = df[, grep("^([XS])",
        colnames(df),
        value = TRUE
      )],
      type = "probs"
    )

    objY0.XS <- nnet::multinom(
      paste("Y~", paste(grep("^([XS])",
        colnames(df),
        value = TRUE
      ), collapse = "+")),
      data = df[train.idx, ],
      subset = A == 0 & D == 1, trace = FALSE
    )
    probY0.XS <- predict(objY0.XS,
      newdata = df[, grep("^([XS])",
        colnames(df),
        value = TRUE
      )],
      type = "probs"
    )

    # check the for missing factor level and impute with zero
    if (ncol(probY1.XS) < length(unique(df$Y))) {
      level.prob <- colnames(probY1.XS)
      level.NA <- setdiff(
        unique(df$Y),
        as.numeric(level.prob)
      )
      probY1.XS <- cbind(
        probY1.XS,
        matrix(0,
          nrow = nrow(probY1.XS),
          ncol = length(level.NA)
        )
      )
      colnames(probY1.XS) <- c(level.prob, level.NA)
    }

    if (ncol(probY0.XS) < length(unique(df$Y))) {
      level.prob <- colnames(probY0.XS)
      level.NA <- setdiff(
        unique(df$Y),
        as.numeric(level.prob)
      )
      probY0.XS <- cbind(
        probY0.XS,
        matrix(0,
          nrow = nrow(probY0.XS),
          ncol = length(level.NA)
        )
      )
      colnames(probY0.XS) <- c(level.prob, level.NA)
    }

    # compute the non-conformity score of each outcomes
    R.XSY1Mat.XS <- apply(probY1.XS, 1, function(x) {
      1 - cumsum(sort(x))[rank(x)]
    }) %>% t()
    R.XSY0Mat.XS <- apply(probY0.XS, 1, function(x) {
      1 - cumsum(sort(x))[rank(x)]
    }) %>% t()


    # choose the observed one based on the outcomes
    df$R.wS <- with(df, mapply(function(row_index, col_index) R.XSY1Mat.XS[row_index, col_index],
      row_index = 1:nrow(R.XSY1Mat.XS),
      col_index = match(
        df$Y,
        as.numeric(colnames(probY1.XS))
      )
    ) * A) +
      with(df, mapply(function(row_index, col_index) R.XSY0Mat.XS[row_index, col_index],
        row_index = 1:nrow(R.XSY0Mat.XS),
        col_index = match(
          df$Y,
          as.numeric(colnames(probY0.XS))
        )
      ) * (1 - A))
  }

  # -------------------------
  # model fitting for nuisance functions
  df.train <- df[train.idx, ]
  df.eval <- df[eval.idx, ]

  model.obj.wS <- list()

  # model training for D|X, A
  psD.obj <-
    model.obj.wS$psD.obj <-
    SuperLearner(
      Y = df.train$D,
      X = df.train[, grep("([XA])",
        colnames(df.train),
        value = TRUE
      ),
      drop = FALSE
      ],
      SL.library = SL.library,
      family = binomial()
    )
  # model for A|X
  psA.obj <-
    model.obj.wS$psA.obj <-
    SuperLearner(
      Y = as.numeric(df.train$A),
      X = df.train[, grep("([X])",
        colnames(df.train),
        value = TRUE
      ),
      drop = FALSE
      ],
      SL.library = SL.library,
      family = binomial()
    )


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
  ## model training with S
  model.obj.wS$mA1.obj <- SuperLearner(
    Y = as.numeric(df.train2$R.wS <= thetaA1.init)[df.train2$D == 1],
    X = df.train2[df.train2$D == 1, grep("^([XSD])",
      colnames(df.train2),
      value = TRUE
    ),
    drop = FALSE
    ],
    SL.library = SL.library,
    family = binomial()
  )

  model.obj.wS$mA1.obj.r <- SuperLearner(
    Y = as.numeric(df.train2$R.wS <= thetaA1.init)[df.train2$D == 1],
    X = df.train2[df.train2$D == 1, grep("^([XD])",
      colnames(df.train2),
      value = TRUE
    ),
    drop = FALSE
    ],
    SL.library = SL.library,
    family = binomial()
  )

  model.obj.wS$mA0.obj <- SuperLearner(
    Y = as.numeric(df.train2$R.wS <= thetaA0.init)[df.train2$D == 1],
    X = df.train2[df.train2$D == 1, grep("^([XSD])",
      colnames(df.train2),
      value = TRUE
    ),
    drop = FALSE
    ],
    SL.library = SL.library,
    family = binomial()
  )

  model.obj.wS$mA0.obj.r <- SuperLearner(
    Y = as.numeric(df.train2$R.wS <= thetaA0.init)[df.train2$D == 1],
    X = df.train2[df.train2$D == 1, grep("^([XD])",
      colnames(df.train2),
      value = TRUE
    ),
    drop = FALSE
    ],
    SL.library = SL.library,
    family = binomial()
  )

  ## construct the estimated cutoff values for the observed outcomes
  ## EIF-based with surrogates
  cutoff.Y1.wS_obs <- tryCatch(
    uniroot(
      f = function(theta) {
        eif_theta(theta,
          df.eval = df.eval,
          model.obj = model.obj.wS,
          target.A = 1, wS = TRUE,
          alphaCI = alphaCI,
          counterfactual = FALSE
        )
      },
      interval = quantile(df.eval$R.wS, c(0.01, 0.99),
        na.rm = TRUE
      ),
      extendInt = "yes",
      maxiter = 100
    )$root,
    error = function(e) {
      quantile(df.eval$R.wS, 1 - alphaCI,
        na.rm = TRUE
      )
    }
  )

  cutoff.Y0.wS_obs <- tryCatch(
    uniroot(
      f = function(theta) {
        eif_theta(theta,
          df.eval = df.eval,
          model.obj = model.obj.wS,
          target.A = 0, wS = TRUE,
          alphaCI = alphaCI,
          counterfactual = FALSE
        )
      },
      interval = quantile(df.eval$R.wS, c(0.01, 0.99),
        na.rm = TRUE
      ),
      extendInt = "yes",
      maxiter = 100
    )$root,
    error = function(e) {
      quantile(df.eval$R.wS, 1 - alphaCI,
        na.rm = TRUE
      )
    }
  )
  ## construct the prediction sets
  if (outcome.type == "Continuous") {
    # conformal inference on the observed outcomes
    # wS
    lower.Y1_A1.wS <- c(predict(m.X1q1.obj,
      newdata = df.eval[, grep("([XA])",
        colnames(df.eval),
        value = TRUE
      )]
    )$pred) -
      cutoff.Y1.wS_obs

    upper.Y1_A1.wS <- c(predict(m.X1q2.obj,
      newdata = df.eval[, grep("([XA])",
        colnames(df.eval),
        value = TRUE
      )]
    )$pred) +
      cutoff.Y1.wS_obs

    lower.Y0_A0.wS <- c(predict(m.X0q1.obj,
      newdata = df.eval[, grep("([XA])",
        colnames(df.eval),
        value = TRUE
      )]
    )$pred) -
      cutoff.Y0.wS_obs

    upper.Y0_A0.wS <- c(predict(m.X0q2.obj,
      newdata = df.eval[, grep("([XA])",
        colnames(df.eval),
        value = TRUE
      )]
    )$pred) +
      cutoff.Y0.wS_obs

    ## for ITE
    # construct the estimated cutoff values for the counterfactual outcomes
    cutoff.Y1.wS <- tryCatch(
      uniroot(
        f = function(theta) {
          eif_theta(theta,
            df.eval = df.eval,
            model.obj = model.obj.wS,
            target.A = 1, wS = TRUE,
            alphaCI = alphaCI
          )
        },
        interval = quantile(df.eval$R.wS, c(0.01, 0.99),
          na.rm = TRUE
        ),
        extendInt = "yes",
        maxiter = 100
      )$root,
      error = function(e) {
        quantile(df.eval$R.wS, 1 - alphaCI,
          na.rm = TRUE
        )
      }
    )

    cutoff.Y0.wS <- tryCatch(
      uniroot(
        f = function(theta) {
          eif_theta(theta,
            df.eval = df.eval,
            model.obj = model.obj.wS,
            target.A = 0, wS = TRUE,
            alphaCI = alphaCI
          )
        },
        interval = quantile(df.eval$R.wS, c(0.01, 0.99),
          na.rm = TRUE
        ),
        extendInt = "yes",
        maxiter = 100
      )$root,
      error = function(e) {
        quantile(df.eval$R.wS, 1 - alphaCI,
          na.rm = TRUE
        )
      }
    )
    # wS
    lower.Y1_A0.wS <- c(predict(m.X1q1.obj,
      newdata = df.eval[, grep("([XA])",
        colnames(df.eval),
        value = TRUE
      )]
    )$pred) -
      cutoff.Y1.wS

    upper.Y1_A0.wS <- c(predict(m.X1q2.obj,
      newdata = df.eval[, grep("([XA])",
        colnames(df.eval),
        value = TRUE
      )]
    )$pred) +
      cutoff.Y1.wS

    lower.Y0_A1.wS <- c(predict(m.X0q1.obj,
      newdata = df.eval[, grep("([XA])",
        colnames(df.eval),
        value = TRUE
      )]
    )$pred) -
      cutoff.Y0.wS

    upper.Y0_A1.wS <- c(predict(m.X0q2.obj,
      newdata = df.eval[, grep("([XA])",
        colnames(df.eval),
        value = TRUE
      )]
    )$pred) +
      cutoff.Y0.wS

    # inference on the observed outcomes
    lower.Y.wS <- lower.Y1_A1.wS * (df.eval$A == 1) +
      lower.Y0_A0.wS * (df.eval$A == 0)
    upper.Y.wS <- upper.Y1_A1.wS * (df.eval$A == 1) +
      upper.Y0_A0.wS * (df.eval$A == 0)

    # inference on tau when A = 0 + A = 1
    lower.tau.wS <- (lower.Y1_A0.wS - (df.eval$Y)) * (df.eval$A == 0) +
      ((df.eval$Y) - upper.Y0_A1.wS) * (df.eval$A == 1)
    upper.tau.wS <- (upper.Y1_A0.wS - (df.eval$Y)) * (df.eval$A == 0) +
      ((df.eval$Y) - lower.Y0_A1.wS) * (df.eval$A == 1)

    # organize the results
    df.eval <- cbind(df.eval,
      lower.Y = lower.Y.wS,
      upper.Y = upper.Y.wS,
      lower.tau = lower.tau.wS,
      upper.tau = upper.tau.wS
    )
    if (nested) {
      # nested conformal inference for the target data where primary outcome is missing
      CI.D0.wS <- conformalIntSplitD0(
        cbind(df.eval,
          lower = lower.tau.wS,
          upper = upper.tau.wS
        )[df.eval$D == 1, ],
        df.eval[df.eval$D == 0, ],
        SL.library = SL.library,
        wS = TRUE
      )
      df.eval$lower.tau.wS[df.eval$D == 0] <- CI.D0.wS$lower
      df.eval$upper.tau.wS[df.eval$D == 0] <- CI.D0.wS$upper
    }
  }
  if (outcome.type == "Categorical") {
    # for A = 0, Y1
    Y1predSet.A1wS <- apply(R.XSY1Mat.XS, 1, function(x) {
      level.Y <- colnames(probY1.XS)[order(x)]
      level.Y[which(x[order(x)] <= cutoff.Y1.wS_obs)]
    }, simplify = FALSE)[eval.idx]

    # for A = 1, Y0
    Y0predSet.A0wS <- apply(R.XSY0Mat.XS, 1, function(x) {
      level.Y <- colnames(probY0.XS)[order(x)]
      level.Y[which(x[order(x)] <= cutoff.Y0.wS_obs)]
    }, simplify = FALSE)[eval.idx]

    # organize the output for the evaluation sets
    ## for the observed one
    ## with surrogates
    df.eval$sets_observed <- Y0predSet.A0wS
    df.eval$sets_observed[df.eval$A == 1] <-
      Y1predSet.A1wS[df.eval$A == 1]
  }

  # return the evaluation df without non-conformal scores
  return(df.eval %>% dplyr::select(-R.wS))
}
