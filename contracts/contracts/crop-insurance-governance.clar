;; Crop Insurance Governance Contract

;; Define constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INVALID_AMOUNT (err u101))

;; Define fungible token for governance
(define-fungible-token CROP_GOV_TOKEN)

;; Define data variables
(define-data-var total-staked uint u0)

;; Define maps
(define-map stakers principal uint)
(define-map proposals
  uint
  { description: (string-utf8 256), votes-for: uint, votes-against: uint, status: (string-ascii 16) }
)

;; Define functions

;; Stake tokens
(define-public (stake-tokens (amount uint))
  (let
    (
      (current-stake (default-to u0 (map-get? stakers tx-sender)))
    )
    (asserts! (>= (stx-get-balance tx-sender) amount) ERR_INVALID_AMOUNT)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set stakers tx-sender (+ current-stake amount))
    (var-set total-staked (+ (var-get total-staked) amount))
    (ok true)
  )
)

;; Unstake tokens
(define-public (unstake-tokens (amount uint))
  (let
    (
      (current-stake (default-to u0 (map-get? stakers tx-sender)))
    )
    (asserts! (>= current-stake amount) ERR_INVALID_AMOUNT)
    (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
    (map-set stakers tx-sender (- current-stake amount))
    (var-set total-staked (- (var-get total-staked) amount))
    (ok true)
  )
)

;; Create a new proposal
(define-public (create-proposal (description (string-utf8 256)))
  (let
    (
      (proposal-id (+ (var-get next-proposal-id) u1))
    )
    (map-set proposals
      proposal-id
      { description: description, votes-for: u0, votes-against: u0, status: "active" }
    )
    (var-set next-proposal-id proposal-id)
    (ok proposal-id)
  )
)

;; Vote on a proposal
(define-public (vote (proposal-id uint) (vote-for bool))
  (let
    (
      (proposal (unwrap-panic (map-get? proposals proposal-id)))
      (voter-stake (default-to u0 (map-get? stakers tx-sender)))
    )
    (asserts! (> voter-stake u0) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status proposal) "active") ERR_UNAUTHORIZED)
    (if vote-for
      (map-set proposals proposal-id (merge proposal { votes-for: (+ (get votes-for proposal) voter-stake) }))
      (map-set proposals proposal-id (merge proposal { votes-against: (+ (get votes-against proposal) voter-stake) }))
    )
    (ok true)
  )
)

;; Get proposal details
(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals proposal-id)
)

;; Get staker's stake
(define-read-only (get-stake (staker principal))
  (default-to u0 (map-get? stakers staker))
)

;; Initialize contract data
(define-data-var next-proposal-id uint u0)
