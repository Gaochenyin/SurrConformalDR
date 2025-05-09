## localized DML
initialize.theta <- function(df.train1,
                             psA.obj, psD.obj,
                             target.A = 1,
                             alphaCI = 0.05) {
  # evaluate the model on train1
  e.X <- c(predict(psA.obj, newdata = df.train1)$pred)
  r.1X <- c(predict(psD.obj, newdata = data.frame(A = 1,
                                                  df.train1[, grep('([X])',
                                                             colnames(df.train1),
                                                             value = TRUE)]))$pred)
  r.0X <- c(predict(psD.obj, newdata = data.frame(A = 0,
                                                  df.train1[, grep('([X])',
                                                             colnames(df.train1),
                                                             value = TRUE)]))$pred)
  pi.X <- (1 - e.X) / e.X
  ## A == 1
  if (target.A == 1) {
    theta.init <- tryCatch(
      uniroot(
        function(theta) {
          psi <- with(
            df.train1,
            -D * (1 - A) * (1 - alphaCI)
          )
          psi[df.train1$D == 1] <- psi[df.train1$D == 1] +
            df.train1$A[df.train1$D == 1] * pi.X[df.train1$D == 1] *
              r.0X[df.train1$D == 1] / r.1X[df.train1$D == 1] *
              ((pull(df.train1, starts_with('R.'))[df.train1$D == 1] <= theta))
          sum(psi, na.rm = TRUE)
        },
        interval = quantile(pull(df.train1, starts_with('R.')), c(0.01, 0.99),
          na.rm = TRUE
        ),
        extendInt = "yes",
        maxiter = 100
      )$root,
      error = function(e) {
        quantile(pull(df.train1, starts_with('R.'))[df.train1$D == 1],
          1 - alphaCI,
          na.rm = TRUE
        )
      }
    )
  }
  if (target.A == 0) {
    theta.init <- tryCatch(
      uniroot(
        function(theta) {
          psi <- with(
            df.train1,
            -D * A * (1 - alphaCI)
          )
          psi[df.train1$D == 1] <- psi[df.train1$D == 1] +
            (1 - df.train1$A)[df.train1$D == 1] / pi.X[df.train1$D == 1] *
              r.1X[df.train1$D == 1] / r.0X[df.train1$D == 1] *
              ((pull(df.train1, starts_with('R.'))[df.train1$D == 1] <= theta))
          sum(psi, na.rm = TRUE)
        },
        interval = quantile(pull(df.train1, starts_with('R.')), c(0.01, 0.99),
          na.rm = TRUE
        ),
        extendInt = "yes",
        maxiter = 100
      )$root,
      error = function(e) {
        quantile(pull(df.train1, starts_with('R.'))[df.train1$D == 1],
          1 - alphaCI,
          na.rm = TRUE
        )
      }
    )
  }
  return(theta.init)
}

## EIF for quantiles for the non-conformity score
eif_theta <- function(theta,
                      df.eval,
                      model.obj,
                      alphaCI = 0.05,
                      wS = TRUE,
                      target.A = 1,
                      counterfactual = TRUE) {
  psD.obj <- model.obj$psD.obj

  if (wS) {
    if (target.A == 1) {
      m.obj <- model.obj$mA1.obj
      m.obj.r <- model.obj$mA1.obj.r
    }

    if (target.A == 0) {
      m.obj <- model.obj$mA0.obj
      m.obj.r <- model.obj$mA0.obj.r
    }

    m.RXS_A1 <- m.RXS_A0 <-
      c(predict(m.obj, newdata = data.frame(df.eval[, grep("^([XSD])",
        colnames(df.eval),
        value = TRUE
      )]))$pred)

    m.RX_A1 <- m.RX_A0 <-
      c(predict(m.obj.r, newdata = data.frame(df.eval[, grep("^([XD])",
        colnames(df.eval),
        value = TRUE
      )]))$pred)
  } else {
    if (target.A == 1) {
      m.obj.r <- model.obj$mA1.obj.r
    }

    if (target.A == 0) {
      m.obj.r <- model.obj$mA0.obj.r
    }

    m.RX_A1 <- m.RX_A0 <- c(predict(m.obj.r,
      newdata = data.frame(df.eval[, grep("^([XD])",
        colnames(df.eval),
        value = TRUE
      )])
    )$pred)
  }
  psA.obj <- model.obj$psA.obj

  e.X <- c(predict(psA.obj, newdata = df.eval)$pred)
  pi.X <- (1 - e.X) / e.X

  # other predictions
  r.1X <- c(predict(psD.obj, newdata = data.frame(
    A = 1,
    df.eval[, grep("([X])",
      colnames(df.eval),
      value = TRUE
    ),
    drop = FALSE
    ]
  ))$pred)
  r.0X <- c(predict(psD.obj, newdata = data.frame(
    A = 0,
    df.eval[, grep("([X])",
      colnames(df.eval),
      value = TRUE
    ),
    drop = FALSE
    ]
  ))$pred)


  # by bias-variance trade-off
  if (target.A == 1) {
    if (wS) {
      if (counterfactual) {
        psi <- with(
          df.eval,
          # A * pi.X * D/r.AX * ( (R <= theta) - m.RX) +
          A * pi.X * r.0X * (m.RXS_A1 - m.RX_A1) +
            D * (1 - A) * (m.RX_A1 - (1 - alphaCI))
        )
        psi[df.eval$D == 1] <- psi[df.eval$D == 1] +
          df.eval$A[df.eval$D == 1] * pi.X[df.eval$D == 1] *
            r.0X[df.eval$D == 1] / r.1X[df.eval$D == 1] *
            ((df.eval$R.wS[df.eval$D == 1] <= theta) - m.RXS_A1[df.eval$D == 1])
        # (1 - df2$A)[df2$D == 1] *
        #   ( m.RX_A1[df2$D == 1] - (1 - alphaCI))
        sum(psi, na.rm = TRUE)
      } else {
        psi <- with(
          df.eval,
          # A * pi.X * D/r.AX * ( (R <= theta) - m.RX) +
          A * r.1X * (m.RXS_A1 - m.RX_A1) +
            D * A * (m.RX_A1 - (1 - alphaCI))
        )
        psi[df.eval$D == 1] <- psi[df.eval$D == 1] +
          df.eval$A[df.eval$D == 1] *
            ((df.eval$R.wS[df.eval$D == 1] <= theta) - m.RXS_A1[df.eval$D == 1])
        # (1 - df2$A)[df2$D == 1] *
        #   ( m.RX_A1[df2$D == 1] - (1 - alphaCI))
        sum(psi, na.rm = TRUE)
      }
    } else {
      if (counterfactual) {
        psi <- with(
          df.eval,
          # A * pi.X * ( (R <= theta) - m.RX) +
          D * (1 - A) * (m.RX_A1 - (1 - alphaCI))
        )
        psi[df.eval$D == 1] <- psi[df.eval$D == 1] +
          df.eval$A[df.eval$D == 1] * pi.X[df.eval$D == 1] *
            r.0X[df.eval$D == 1] / r.1X[df.eval$D == 1] *
            ((df.eval$R.woS[df.eval$D == 1] <= theta) - m.RX_A1[df.eval$D == 1])
        sum(psi, na.rm = TRUE)
      } else {
        psi <- with(
          df.eval,
          # A * pi.X * ( (R <= theta) - m.RX) +
          D * A * (m.RX_A1 - (1 - alphaCI))
        )
        psi[df.eval$D == 1] <- psi[df.eval$D == 1] +
          df.eval$A[df.eval$D == 1] *
            ((df.eval$R.woS[df.eval$D == 1] <= theta) - m.RX_A1[df.eval$D == 1])
        sum(psi, na.rm = TRUE)
      }
    }
  } else {
    if (wS) {
      if (counterfactual) {
        psi <- with(
          df.eval,
          # (1 - A) * pi.X * D/r.AX * ( (R <= theta) - m.RX) +
          (1 - A) / pi.X * r.1X * (m.RXS_A0 - m.RX_A0) +
            D * A * (m.RX_A0 - (1 - alphaCI))
        )
        psi[df.eval$D == 1] <- psi[df.eval$D == 1] +
          (1 - df.eval$A)[df.eval$D == 1] / pi.X[df.eval$D == 1] *
            r.1X[df.eval$D == 1] / r.0X[df.eval$D == 1] *
            ((df.eval$R.wS[df.eval$D == 1] <= theta) - m.RXS_A0[df.eval$D == 1])
        sum(psi,
          na.rm = TRUE
        )
      } else {
        psi <- with(
          df.eval,
          # (1 - A) * pi.X * D/r.AX * ( (R <= theta) - m.RX) +
          (1 - A) * r.0X * (m.RXS_A0 - m.RX_A0) +
            D * (1 - A) * (m.RX_A0 - (1 - alphaCI))
        )
        psi[df.eval$D == 1] <- psi[df.eval$D == 1] +
          (1 - df.eval$A)[df.eval$D == 1] *
            ((df.eval$R.wS[df.eval$D == 1] <= theta) - m.RXS_A0[df.eval$D == 1])
        sum(psi,
          na.rm = TRUE
        )
      }
    } else {
      if (counterfactual) {
        psi <- with(
          df.eval,
          # (1 - A) * pi.X * ( (R <= theta) - m.RX) +
          D * A * (m.RX_A0 - (1 - alphaCI))
        )
        psi[df.eval$D == 1] <- psi[df.eval$D == 1] +
          (1 - df.eval$A)[df.eval$D == 1] / pi.X[df.eval$D == 1] *
            r.1X[df.eval$D == 1] / r.0X[df.eval$D == 1] *
            ((df.eval$R.woS[df.eval$D == 1] <= theta) - m.RX_A0[df.eval$D == 1])
        sum(psi, na.rm = TRUE)
      } else {
        psi <- with(
          df.eval,
          # (1 - A) * pi.X * ( (R <= theta) - m.RX) +
          D * (1 - A) * (m.RX_A0 - (1 - alphaCI))
        )
        psi[df.eval$D == 1] <- psi[df.eval$D == 1] +
          (1 - df.eval$A)[df.eval$D == 1] *
            ((df.eval$R.woS[df.eval$D == 1] <= theta) - m.RX_A0[df.eval$D == 1])
        sum(psi, na.rm = TRUE)
      }
    }
  }
}

# jointly calibrate C^L and C^R when both potential outcomes are missing
## continuous outcome only
conformalIntSplitD0 <- function(df.D1,
                                df.D0,
                                wS = TRUE,
                                SL.library = "SL.glm") {
  # split for modeling
  foldsCI.idx <- caret::createFolds(1:nrow(df.D1), k = 2)
  trainCI.idx <- foldsCI.idx[[1]]
  evalCI.idx <- foldsCI.idx[[2]]
  # model fitting
  if (wS) {
    lowerCI.obj <- SuperLearner(
      Y = df.D1[trainCI.idx, ]$lower,
      X = df.D1[trainCI.idx, grep("^([XSA])",
        colnames(df.D1),
        value = TRUE
      )],
      SL.library = SL.library
    )

    upperCI.obj <- SuperLearner(
      Y = df.D1[trainCI.idx, ]$upper,
      X = df.D1[trainCI.idx, grep("^([XSA])",
        colnames(df.D1),
        value = TRUE
      )],
      SL.library = SL.library
    )
  } else {
    lowerCI.obj <- SuperLearner(
      Y = df.D1[trainCI.idx, ]$lower,
      X = df.D1[trainCI.idx, grep("^([XA])",
        colnames(df.D1),
        value = TRUE
      )],
      SL.library = SL.library
    )

    upperCI.obj <- SuperLearner(
      Y = df.D1[trainCI.idx, ]$upper,
      X = df.D1[trainCI.idx, grep("^([XA])",
        colnames(df.D1),
        value = TRUE
      )],
      SL.library = SL.library
    )
  }



  df.piD <- rbind(
    cbind(
      D = 1,
      df.D1[trainCI.idx, grep("([XA])",
        colnames(df.D1),
        value = TRUE
      )]
    ),
    cbind(
      D = 0,
      df.D0[, grep("([XA])",
        colnames(df.D0),
        value = TRUE
      )]
    )
  )

  piD.obj <- SuperLearner(
    Y = df.piD$D,
    X = df.piD[, grep("([XA])",
      colnames(df.piD),
      value = TRUE
    )],
    SL.library = SL.library,
    family = binomial()
  )

  # compute non-conformity score
  R.CI <- c(pmax(
    predict(lowerCI.obj, newdata = df.D1)$pred - df.D1$lower,
    df.D1$upper - predict(upperCI.obj, newdata = df.D1)$pred
  ))
  # fit model on R.CI with trainCI.idx
  mC.wS.obj <- NULL
  if (wS) {
    mC.wS.obj <- SuperLearner(
      Y = R.CI[trainCI.idx],
      X = df.D1[
        trainCI.idx,
        grep("^[XSA]",
          colnames(df.D1),
          value = TRUE
        )
      ],
      SL.library = SL.library
    )
  }

  mC.woS.obj <- SuperLearner(
    Y = R.CI[trainCI.idx],
    X = df.D1[
      trainCI.idx,
      grep("^[XA]",
        colnames(df.D1),
        value = TRUE
      )
    ],
    SL.library = SL.library
  )
  # predict on D = 0
  predict.conformalIntD0 <- function(lowerCI.obj, # model fit for lower bound
                                     upperCI.obj, # model fit for upper bound
                                     piD.obj, # model fit for D
                                     mC.wS.obj, # model fit for R_C (with S)
                                     mC.woS.obj, # model fit for R_C (without S)
                                     # eval
                                     wD, # weights
                                     df.D1, # df for D = 1 for calibration
                                     df.D0, # df for D = 0 for testing
                                     alphaCI.Int = 0.01, # alpha for interval
                                     wS = TRUE # use surrogates or not
  ) {
    # compute non-conformity scores
    R.CI <- c(pmax(
      predict(lowerCI.obj, newdata = df.D1)$pred - df.D1$lower,
      df.D1$upper - predict(upperCI.obj, newdata = df.D1)$pred
    ))

    piD0.eval <- c(predict(piD.obj, newdata = df.D0)$pred)
    piD1.eval <- c(predict(piD.obj, newdata = df.D1)$pred)
    wD.eval <- (1 - piD1.eval) / piD1.eval

    # doubly robust for estimating the thresholds of confidence intervals
    if (wS) {
      mC.woS.D1 <- c(predict(mC.woS.obj, newdata = df.D1)$pred)
      mC.wS.D1 <- c(predict(mC.wS.obj, newdata = df.D1)$pred)

      mC.woS.D0 <- c(predict(mC.woS.obj, newdata = df.D0)$pred)
      mC.wS.D0 <- c(predict(mC.wS.obj, newdata = df.D0)$pred)

      eif_thetaC <- function(theta_C,
                             alphaCI_C = 0.05) {
        sum(mC.woS.D0 - (1 - alphaCI_C)) +
          sum((1 - piD0.eval) * (mC.wS.D0 - mC.woS.D0)) +
          sum((1 - piD1.eval) * (mC.wS.D1 - mC.woS.D1)) +
          sum(wD.eval * ((R.CI < theta_C) - mC.wS.D1))
      }
      cutoff <- tryCatch(
        uniroot(
          f = function(theta_C) {
            eif_thetaC(theta_C,
              alphaCI = alphaCI.Int
            )
          },
          interval = quantile(R.CI, c(0.01, 0.99),
            na.rm = TRUE
          ),
          extendInt = "yes",
          maxiter = 100
        )$root,
        error = function(e) {
          quantile(R.CI, .95,
            na.rm = TRUE
          )
        }
      )
    } else {
      mC.woS.D1 <- predict(mC.woS.obj, newdata = df.D1)

      mC.woS.D0 <- predict(mC.woS.obj, newdata = df.D0)

      eif_thetaC <- function(theta_C,
                             alphaCI_C = 0.05) {
        sum(mC.woS.D0 - (1 - alphaCI_C)) +
          # sum((1-piD0.eval) * (mC.wS.D0 -mC.woS.D0)) +
          # sum((1-piD1.eval) * (mC.wS.D1 -mC.woS.D1)) +
          sum(wD.eval * ((R.CI < theta_C) - mC.woS.D1))
      }
      cutoff <- tryCatch(
        uniroot(
          f = function(theta_C) {
            eif_thetaC(theta_C,
              alphaCI = alphaCI.Int
            )
          },
          interval = quantile(R.CI, c(0.01, 0.99),
            na.rm = TRUE
          ),
          extendInt = "yes",
          maxiter = 100
        )$root,
        error = function(e) {
          quantile(R.CI, .95,
            na.rm = TRUE
          )
        }
      )
    }
    # # adapted from
    # # https://github.com/lihualei71/cfcausal/blob/master/R/conformalInt_split.R
    # avg_wt <- mean(c(wD, wD.eval))
    # wD <- wD/avg_wt; wD.eval <- wD.eval/avg_wt
    # totw <- sum(wD); wD <- wD/totw
    # qt <- (1 + wD.eval/totw) * (1 - alphaCI.Int)
    #
    # # compute he cutoff for non-conformity score
    # ord <- order(R.CI)
    # wD <- wD[ord]
    # R.CI <- R.CI[ord]
    # cwD <- cumsum(wD)
    #
    # find_inds <- function(a, b){
    #   n <- length(a)
    #   b <- b - 1e-12
    #   ## n + 1 - rank(-c(a, b), ties.method = "first")[-(1:n)] + rank(-b, ties.method = "first")
    #   rank(c(a, b), ties.method = "first")[-(1:n)] - rank(b, ties.method = "first") + 1
    # }
    # inds <- find_inds(cwD, pmin(qt, 1))
    # cutoff <- R.CI[inds]

    lower.tauD0 <- predict(lowerCI.obj, newdata = df.D0)$pred - cutoff
    upper.tauD0 <- predict(upperCI.obj, newdata = df.D0)$pred + cutoff

    data.frame(
      lower = lower.tauD0,
      upper = upper.tauD0
    )
  }

  CI.D0 <- predict.conformalIntD0(
    lowerCI.obj = lowerCI.obj,
    upperCI.obj = upperCI.obj,
    piD.obj = piD.obj,
    mC.wS.obj = mC.wS.obj,
    mC.woS.obj = mC.woS.obj,
    wD = wD,
    df.D1 = df.D1[evalCI.idx, ],
    df.D0 = df.D0,
    alphaCI.Int = 0.01,
    wS = wS
  )
  CI.D0
}

#' Generate data for ReadMe continuous example
#'
#' @export
genData.conformal <- function(seed, N,
                              outcome.type = c("Continuous", "Categorical"),
                              beta.S = 1,
                              alpha.r = 3 / 4) {
  outcome.type <- match.arg(outcome.type)
  # generate X
  X <- cbind(
    rnorm(N, mean = 1),
    rnorm(N, mean = 1)
  )
  # with proportion 0.6, 0.3, 0.1
  # generate D
  n_idx <- sample(1:N, size = N^(alpha.r))
  m_idx <- setdiff(1:N, n_idx)
  n <- length(n_idx)
  m <- length(m_idx)

  # generate A
  alpha0.opt <- uniroot(function(alpha0) {
    mean(expit(alpha0 + X %*% c(-1 / 2, -1 / 2))) - 1 / 2
  }, interval = c(-5, 5))$root
  A <- rbinom(N,
    size = 1,
    prob = expit(alpha0.opt + X %*% c(-1 / 2, -1 / 2))
  )
  # A <- rbinom(N, size = 1,
  #             prob = 0.3)
  # generate S
  S0 <- cbind(
    rnorm(N, mean = -1, sd = beta.S),
    rnorm(N, mean = -1, sd = beta.S)
  )
  S1 <- cbind(
    rnorm(N, mean = 1, sd = beta.S),
    rnorm(N, mean = 1, sd = beta.S)
  )
  if (outcome.type == "Continuous") {
    # generate Y (by Gaussian)
    Y0 <- -1 +
      -1 / 2 * apply(S0, 1, sum) / 5 +
      X %*% c(1, 1) + rnorm(N)
    Y1 <- 1 +
      1 / 2 * apply(S1, 1, sum) / 5 +
      X %*% c(1, 1) + rnorm(N)
  }

  if (outcome.type == "Categorical") {
    # generate discrete outcomes
    alpha0.Y.opt <- rootSolve::multiroot(
      f = function(alpha0.Y) {
        # with prob (0.3, 0.3, 0.2, 0.15, 0.05)
        prob_Y <- cbind(
          1,
          exp(alpha0.Y[1] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S0, 1, sum)),
          exp(alpha0.Y[2] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S0, 1, sum)),
          exp(alpha0.Y[3] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S0, 1, sum)),
          exp(alpha0.Y[4] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S0, 1, sum))
        )
        apply(prob_Y / apply(prob_Y, 1, sum), 2, mean)[c(-1)] -
          c(0.3, 0.2, 0.15, 0.05)
      }, start = c(0, 0, 0, 0),
      maxiter = 100
    )$root

    alpha1.Y.opt <- rootSolve::multiroot(
      f = function(alpha1.Y) {
        # with prob (0.1, 0.2, 0.4, 0.15, 0.15)
        prob_Y <- cbind(
          1,
          exp(alpha1.Y[1] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S1, 1, sum)),
          exp(alpha1.Y[2] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S1, 1, sum)),
          exp(alpha1.Y[3] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S1, 1, sum)),
          exp(alpha1.Y[4] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S1, 1, sum))
        )
        apply(prob_Y / apply(prob_Y, 1, sum), 2, mean)[c(-1)] -
          c(0.2, 0.4, 0.15, 0.15)
      }, start = c(0, 0, 0, 0),
      maxiter = 100
    )$root


    Y0 <- apply(
      cbind(
        1,
        exp(alpha0.Y.opt[1] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S0, 1, sum)),
        exp(alpha0.Y.opt[2] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S0, 1, sum)),
        exp(alpha0.Y.opt[3] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S0, 1, sum)),
        exp(alpha0.Y.opt[4] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S0, 1, sum))
      ),
      1, function(x) {
        sample(1:5,
          size = 1,
          prob = x
        )
      }
    )

    Y1 <- apply(
      cbind(
        1,
        exp(alpha1.Y.opt[1] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S1, 1, sum)),
        exp(alpha1.Y.opt[2] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S1, 1, sum)),
        exp(alpha1.Y.opt[3] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S1, 1, sum)),
        exp(alpha1.Y.opt[4] + X %*% c(-1 / 2, -1 / 2) - 1 / 2 * apply(S1, 1, sum))
      ),
      1, function(x) {
        sample(1:5,
          size = 1,
          prob = x
        )
      }
    )
  }
  # df_source and df_target
  ## setting 2
  df_source <- data.frame(
    X = X[n_idx, ],
    A = A[n_idx],
    S = (S1 * A)[n_idx, ] +
      (S0 * (1 - A))[n_idx, ],
    # Y1 = Y1[n_idx],
    # Y0 = Y0[n_idx],
    Y = (Y1 * A)[n_idx] +
      (Y0 * (1 - A))[n_idx]
  )
  df_target <- data.frame(
    X = X[m_idx, ],
    A = A[m_idx],
    # S = cbind(rep(NA, m),
    #           rep(NA, m)),
    S = (S1 * A)[m_idx, ] +
      (S0 * (1 - A))[m_idx, ],
    # Y1 = Y1[m_idx],
    # Y0 = Y0[m_idx],
    Y = NA
    # Y = (Y1 * A)[m_idx] +
    #   (Y0 * (1 - A))[m_idx]
  )

  if (outcome.type == "Continuous") {
    tauITE <- (Y1 - Y0)[c(n_idx, m_idx)]

    df <- cbind(
      rbind(
        cbind(D = 1, df_source),
        cbind(D = 0, df_target)
      ),
      tau = tauITE
    )
  }

  if (outcome.type == "Categorical") {
    df <- cbind(rbind(
      cbind(D = 1, df_source),
      cbind(D = 0, df_target)
    ))
  }

  return(df)
}

expit <- function(x) {
  exp(x) / (1 + exp(x))
}

#' Generate data for ReadMe categorical example with protected groups
#'
#' @export
genData.clustered.conformal <- function(seed, N,
                              numgroup = 10,
                              numcluster = 5,
                              outcome.type = c('Continuous', 'Categorical'),
                              beta.S = 10,
                              alpha.r = 9/10){
  outcome.type <- match.arg(outcome.type)
  # generate X
  X <- cbind(rnorm(N, mean = 1),
             rnorm(N, mean = 1))
  # generate group indicator
  # alpha0.R.opt <- rootSolve::multiroot(f = function(alpha0.R){
  #   prob_R <- cbind(exp(X%*%c(-1/2, -1/2)),
  #                   exp(alpha0.R[1]+X%*%c(-1, -1/2)),
  #                   exp(alpha0.R[2]+X%*%c(-1/2, -1)),
  #                   exp(alpha0.R[3]+X%*%c(-1, -1/2)),
  #                   exp(alpha0.R[4]+X%*%c(-1, -1/2)),
  #                   exp(alpha0.R[5]+X%*%c(-1, -1/2)))
  #   apply(prob_R/apply(prob_R, 1, sum), 2, mean)[c(1:5)] -
  #     c(0.3, 0.2, 0.15, 0.15, 0.1)
  # }, start = c(0, 0, 0, 0, 0),
  # maxiter = 100)$root
  #
  # prob_R <- cbind(exp(X%*%c(-1/2, -1/2)),
  #                 exp(alpha0.R.opt[1]+X%*%c(-1, -1/2)),
  #                 exp(alpha0.R.opt[2]+X%*%c(-1/2, -1)),
  #                 exp(alpha0.R.opt[3]+X%*%c(-1, -1/2)),
  #                 exp(alpha0.R.opt[4]+X%*%c(-1, -1/2)),
  #                 exp(alpha0.R.opt[5]+X%*%c(-1, -1/2)))
  # R <- apply(prob_R, 1, function(x)sample(1:6, size = 1,
  #                                         prob = x))

  # alpha0.R.opt <- rootSolve::multiroot(f = function(alpha0.R){
  #   prob_R <- cbind(exp(X%*%c(-1/2, -1/2)),
  #                   exp(alpha0.R[1]+X%*%c(-1, -1/2)),
  #                   exp(alpha0.R[2]+X%*%c(-1/2, -1)))
  #   apply(prob_R/apply(prob_R, 1, sum), 2, mean)[c(1:2)] -
  #     c(0.3, 0.3)
  # }, start = c(0, 0),
  # maxiter = 100)$root
  #
  # prob_R <- cbind(exp(X%*%c(-1/2, -1/2)),
  #                 exp(alpha0.R.opt[1]+X%*%c(-1, -1/2)),
  #                 exp(alpha0.R.opt[2]+X%*%c(-1/2, -1)))
  # R <- apply(prob_R, 1, function(x)sample(1:3, size = 1,
  #                                         prob = x))
  R <- sample(1:numgroup, size = N, replace = TRUE)
  R.effect <- cut(R, numcluster) %>% as.numeric()
  # with proportion 0.6, 0.3, 0.1
  # generate D
  n_idx <- sample(1:N, size = N^(alpha.r))
  m_idx <- setdiff(1:N, n_idx)
  n <- length(n_idx); m <- length(m_idx)

  # generate A
  alpha0.opt <- uniroot(function(alpha0){
    mean(expit(alpha0 + X%*%c(-1/2, -1/2) + R)) - 1/2
  }, interval = c(-50, 50))$root
  A <- rbinom(N, size = 1, prob = 0.5)
  # A <- rbinom(N, size = 1,
  #             prob = 0.3)
  # generate S
  if(beta.S == 0){
    S0 <- cbind(rep(0, N),rep(0, N))
    S1 <- cbind(rep(0, N),rep(0, N))
  }else{
    S0 <- cbind(rnorm(N, mean = -1, sd = beta.S),
                rnorm(N, mean = -1, sd = beta.S))
    S1 <- cbind(rnorm(N, mean = 1, sd = beta.S),
                rnorm(N, mean = 1, sd = beta.S))
  }

  if(outcome.type == 'Continuous'){
    # generate Y (by Gaussian)
    Y0 <- -1 +
      -1/2 * apply(S0, 1, sum) / 5 + 3 * R +
      X%*%c(1, 1) + rnorm(N)
    Y1 <- 1 +
      1/2 * apply(S1, 1, sum) / 5 + 3 * R +
      X%*%c(1, 1) + rnorm(N)

  }

  if(outcome.type == 'Categorical'){
    # generate discrete outcomes
    alpha0.Y.opt <- rootSolve::multiroot(f = function(alpha0.Y){
      # with prob (0.3, 0.3, 0.2, 0.15, 0.05)
      prob_Y <- cbind(1,
                      exp(alpha0.Y[1]+X%*%c(-1, -1)*R.effect/numcluster -1/2 * apply(S0, 1, sum)),
                      exp(alpha0.Y[2]+X%*%c(-1, 1)*R.effect/numcluster +1/2 * apply(S0, 1, sum)),
                      exp(alpha0.Y[3]+X%*%c(1, -1)*R.effect/numcluster -1/2 * apply(S0, 1, sum)),
                      exp(alpha0.Y[4]+X%*%c(1, 1)*R.effect/numcluster +1/2 * apply(S0, 1, sum))
      )
      apply(prob_Y/apply(prob_Y, 1, sum), 2, mean)[c(-1)] -
        c(0.3, 0.2, 0.15, 0.1)
    }, start = c(0, 0, 0, 0),
    maxiter = 100)$root

    alpha1.Y.opt <- rootSolve::multiroot(f = function(alpha1.Y){
      # with prob (0.1, 0.2, 0.4, 0.15, 0.15)
      prob_Y <- cbind(1,
                      exp(alpha1.Y[1]+X%*%c(-1, -1)*R.effect/numcluster -1/2 * apply(S1, 1, sum)),
                      exp(alpha1.Y[2]+X%*%c(-1, 1)*R.effect/numcluster +1/2 * apply(S1, 1, sum)),
                      exp(alpha1.Y[3]+X%*%c(1, -1)*R.effect/numcluster -1/2 * apply(S1, 1, sum)),
                      exp(alpha1.Y[4]+X%*%c(1, 1)*R.effect/numcluster +1/2 * apply(S1, 1, sum))
      )
      apply(prob_Y/apply(prob_Y, 1, sum), 2, mean)[c(-1)] -
        c(0.2, 0.3, 0.15, 0.15)
    }, start = c(0, 0, 0, 0),
    maxiter = 100)$root


    Y0 <- apply(cbind(1,
                      exp(alpha0.Y.opt[1]+X%*%c(-1, -1)*R.effect/numcluster -1/2 * apply(S0, 1, sum)),
                      exp(alpha0.Y.opt[2]+X%*%c(-1, 1)*R.effect/numcluster +1/2 * apply(S0, 1, sum)),
                      exp(alpha0.Y.opt[3]+X%*%c(1, -1)*R.effect/numcluster -1/2 * apply(S0, 1, sum)),
                      exp(alpha0.Y.opt[4]+X%*%c(1, 1)*R.effect/numcluster +1/2 * apply(S0, 1, sum))),
                1, function(x)sample(1:5, size = 1,
                                     prob = x))

    Y1 <- apply(cbind(1,
                      exp(alpha1.Y.opt[1]+X%*%c(-1, -1)*R.effect/numcluster -1/2 * apply(S1, 1, sum)),
                      exp(alpha1.Y.opt[2]+X%*%c(-1, 1)*R.effect/numcluster +1/2 * apply(S1, 1, sum)),
                      exp(alpha1.Y.opt[3]+X%*%c(1, -1)*R.effect/numcluster -1/2 * apply(S1, 1, sum)),
                      exp(alpha1.Y.opt[4]+X%*%c(1, 1)*R.effect/numcluster +1/2 * apply(S1, 1, sum))),
                1, function(x)sample(1:5, size = 1,
                                     prob = x))

  }
  # df_source and df_target
  ## setting 2
  df_source <- data.frame(X = X[n_idx, ],
                          R = R[n_idx],
                          A = A[n_idx],
                          S = (S1 * A)[n_idx, ] +
                            (S0 * (1 - A))[n_idx, ],
                          Y1 = Y1[n_idx],
                          Y0 = Y0[n_idx],
                          Y = (Y1 * A)[n_idx] +
                            (Y0 * (1 - A))[n_idx])
  df_target <- data.frame(X = X[m_idx, ],
                          A = A[m_idx],
                          R = R[m_idx],
                          # S = cbind(rep(NA, m),
                          #           rep(NA, m)),
                          S = (S1 * A)[m_idx, ] +
                            (S0 * (1 - A))[m_idx, ],
                          Y1 = Y1[m_idx],
                          Y0 = Y0[m_idx],
                          # Y = NA
                          Y = (Y1 * A)[m_idx] +
                            (Y0 * (1 - A))[m_idx]
  )

  if(outcome.type == 'Continuous'){
    tauITE <- (Y1 - Y0)[c(n_idx, m_idx)]

    df <- cbind(rbind(cbind(D = 1, df_source),
                      cbind(D = 0, df_target)),
                tau = tauITE)}

  if(outcome.type == 'Categorical'){
    df <- cbind(rbind(cbind(D = 1, df_source),
                      cbind(D = 0, df_target)))
  }

  return(df)
}

#' Compute the metrics to evaluation the efficiency and fairness
#'
#' @export
get.metric <- function(rst){
  cp.R <- by(rst, list(group = rst$R), function(df_R){
    mapply(function(y, set)!is.na(match(y, set)),
           y = df_R$Y,
           set = df_R$sets_observed) %>%
      mean(na.rm = TRUE)
  }) %>% array2DF()

  wl.R <- by(rst, list(group = rst$R), function(df_R){
    sapply(df_R$sets_observed, length) %>%
      mean()
  }) %>% array2DF()

  cp.R <- cp.R$Value; wl.R <- wl.R$Value

  c(CovGap = 100 * mean(abs(cp.R - (1 - 0.05)),
                        na.rm = TRUE),
    AvgSize = mean(wl.R, na.rm = TRUE))
}
