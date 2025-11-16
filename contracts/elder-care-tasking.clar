;; ElderCareTasking - Daily Care Task Management System
;; Manages daily care tasks and completion tracking for elderly patients

(define-map patients
  { patient-id: uint }
  {
    patient-principal: principal,
    patient-name: (string-ascii 100),
    care-level: (string-ascii 20),
    assigned-caregiver: principal,
    enrollment-block: uint,
    is-active: bool
  }
)

(define-map care-tasks
  { task-id: uint }
  {
    patient-id: uint,
    task-type: (string-ascii 50),
    task-description: (string-ascii 200),
    scheduled-block: uint,
    priority: (string-ascii 20),
    is-recurring: bool,
    created-by: principal
  }
)

(define-map task-completions
  { completion-id: uint }
  {
    task-id: uint,
    completed-by: principal,
    completion-block: uint,
    notes: (string-ascii 200),
    completion-status: (string-ascii 20)
  }
)

(define-map daily-assessments
  { assessment-id: uint }
  {
    patient-id: uint,
    assessment-date: uint,
    vitals-checked: bool,
    meals-completed: uint,
    mobility-score: uint,
    mood-rating: uint,
    assessed-by: principal
  }
)

(define-data-var next-patient-id uint u1)
(define-data-var next-task-id uint u1)
(define-data-var next-completion-id uint u1)
(define-data-var next-assessment-id uint u1)

(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u200))
(define-constant err-not-found (err u201))
(define-constant err-invalid-input (err u202))
(define-constant err-already-completed (err u203))
(define-constant err-not-active (err u204))

;; Enroll new patient
(define-public (enroll-patient
  (patient-principal principal)
  (patient-name (string-ascii 100))
  (care-level (string-ascii 20))
  (assigned-caregiver principal)
)
  (let
    (
      (patient-id (var-get next-patient-id))
    )
    (asserts! (> (len patient-name) u0) err-invalid-input)
    (asserts! (> (len care-level) u0) err-invalid-input)
    
    (map-set patients
      { patient-id: patient-id }
      {
        patient-principal: patient-principal,
        patient-name: patient-name,
        care-level: care-level,
        assigned-caregiver: assigned-caregiver,
        enrollment-block: stacks-block-height,
        is-active: true
      }
    )
    
    (var-set next-patient-id (+ patient-id u1))
    (ok patient-id)
  )
)

;; Create care task
(define-public (create-care-task
  (patient-id uint)
  (task-type (string-ascii 50))
  (task-description (string-ascii 200))
  (scheduled-block uint)
  (priority (string-ascii 20))
  (is-recurring bool)
)
  (let
    (
      (patient-data (unwrap! (map-get? patients { patient-id: patient-id }) err-not-found))
      (task-id (var-get next-task-id))
    )
    (asserts! (get is-active patient-data) err-not-active)
    (asserts! (> (len task-type) u0) err-invalid-input)
    (asserts! (>= scheduled-block stacks-block-height) err-invalid-input)
    
    (map-set care-tasks
      { task-id: task-id }
      {
        patient-id: patient-id,
        task-type: task-type,
        task-description: task-description,
        scheduled-block: scheduled-block,
        priority: priority,
        is-recurring: is-recurring,
        created-by: tx-sender
      }
    )
    
    (var-set next-task-id (+ task-id u1))
    (ok task-id)
  )
)

;; Complete care task
(define-public (complete-task
  (task-id uint)
  (notes (string-ascii 200))
  (completion-status (string-ascii 20))
)
  (let
    (
      (task-data (unwrap! (map-get? care-tasks { task-id: task-id }) err-not-found))
      (completion-id (var-get next-completion-id))
    )
    (asserts! (> (len completion-status) u0) err-invalid-input)
    
    (map-set task-completions
      { completion-id: completion-id }
      {
        task-id: task-id,
        completed-by: tx-sender,
        completion-block: stacks-block-height,
        notes: notes,
        completion-status: completion-status
      }
    )
    
    (var-set next-completion-id (+ completion-id u1))
    (ok completion-id)
  )
)

;; Record daily assessment
(define-public (record-daily-assessment
  (patient-id uint)
  (vitals-checked bool)
  (meals-completed uint)
  (mobility-score uint)
  (mood-rating uint)
)
  (let
    (
      (patient-data (unwrap! (map-get? patients { patient-id: patient-id }) err-not-found))
      (assessment-id (var-get next-assessment-id))
    )
    (asserts! (get is-active patient-data) err-not-active)
    (asserts! (<= meals-completed u4) err-invalid-input)
    (asserts! (<= mobility-score u10) err-invalid-input)
    (asserts! (<= mood-rating u10) err-invalid-input)
    
    (map-set daily-assessments
      { assessment-id: assessment-id }
      {
        patient-id: patient-id,
        assessment-date: stacks-block-height,
        vitals-checked: vitals-checked,
        meals-completed: meals-completed,
        mobility-score: mobility-score,
        mood-rating: mood-rating,
        assessed-by: tx-sender
      }
    )
    
    (var-set next-assessment-id (+ assessment-id u1))
    (ok assessment-id)
  )
)

;; Reassign caregiver
(define-public (reassign-caregiver (patient-id uint) (new-caregiver principal))
  (let
    (
      (patient-data (unwrap! (map-get? patients { patient-id: patient-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    
    (map-set patients
      { patient-id: patient-id }
      (merge patient-data { assigned-caregiver: new-caregiver })
    )
    (ok true)
  )
)

;; Get patient information
(define-read-only (get-patient (patient-id uint))
  (map-get? patients { patient-id: patient-id })
)

;; Get care task
(define-read-only (get-care-task (task-id uint))
  (map-get? care-tasks { task-id: task-id })
)

;; Get task completion
(define-read-only (get-task-completion (completion-id uint))
  (map-get? task-completions { completion-id: completion-id })
)

;; Get daily assessment
(define-read-only (get-daily-assessment (assessment-id uint))
  (map-get? daily-assessments { assessment-id: assessment-id })
)

;; Check if patient is active
(define-read-only (is-patient-active (patient-id uint))
  (match (map-get? patients { patient-id: patient-id })
    patient-data
    (get is-active patient-data)
    false
  )
)

;; Discharge patient
(define-public (discharge-patient (patient-id uint))
  (let
    (
      (patient-data (unwrap! (map-get? patients { patient-id: patient-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-unauthorized)
    
    (map-set patients
      { patient-id: patient-id }
      (merge patient-data { is-active: false })
    )
    (ok true)
  )
)