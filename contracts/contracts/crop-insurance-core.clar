;; Crop Insurance Core Contract

;; Define constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))

;; Define data variables
(define-data-var insurance-pool uint u0)

;; Define maps
(define-map policies
  { farmer: principal, policy-id: uint }
  { crop-type: (string-ascii 64), coverage-amount: uint, duration: uint, premium: uint, active: bool }
)

(define-map weather-data
  { timestamp: uint }
  { rainfall: uint, temperature: uint, wind-speed: uint, humidity: uint }
)

;; Define functions

;; Purchase a policy
(define-public (purchase-policy (crop-type (string-ascii 64)) (coverage-amount uint) (duration uint))
  (let
    (
      (premium (calculate-premium crop-type coverage-amount duration))
      (policy-id (+ (var-get next-policy-id) u1))
    )
    (asserts! (>= (stx-get-balance tx-sender) premium) ERR_INVALID_AMOUNT)
    (try! (stx-transfer? premium tx-sender (as-contract tx-sender)))
    (var-set insurance-pool (+ (var-get insurance-pool) premium))
    (map-set policies
      { farmer: tx-sender, policy-id: policy-id }
      { crop-type: crop-type, coverage-amount: coverage-amount, duration: duration, premium: premium, active: true }
    )
    (var-set next-policy-id policy-id)
    (ok policy-id)
  )
)

;; Internal function to calculate premium (simplified)
(define-private (calculate-premium (crop-type (string-ascii 64)) (coverage-amount uint) (duration uint))
  ;; Simplified premium calculation
  (/ (* coverage-amount duration) u100)
)

;; Update weather data (only callable by authorized oracle)
(define-public (update-weather-data (rainfall uint) (temperature uint) (wind-speed uint) (humidity uint))
  (let
    ((timestamp stacks-block-height))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set weather-data
      { timestamp: timestamp }
      { rainfall: rainfall, temperature: temperature, wind-speed: wind-speed, humidity: humidity }
    )
    (process-payouts timestamp)
    (ok true)
  )
)

;; Process payouts based on weather data
(define-private (process-payouts (timestamp uint))
  (let
    (
      (weather (unwrap-panic (map-get? weather-data { timestamp: timestamp })))
      (rainfall (get rainfall weather))
    )
    ;; Simplified payout logic based on rainfall
    (if (< rainfall u100)
      (make-payouts)
      true
    )
  )
)

;; Make payouts to eligible farmers
(define-private (make-payouts)
  ;; Simplified payout logic
  ;; In a real implementation, you would iterate through policies and make payouts
  true
)

;; Get policy details
(define-read-only (get-policy (farmer principal) (policy-id uint))
  (map-get? policies { farmer: farmer, policy-id: policy-id })
)

;; Initialize contract data
(define-data-var next-policy-id uint u0)
