# ElderCareTasking - Daily Care Task Management System

A blockchain-based system for managing daily care tasks and assessments for elderly patients on Stacks.

## Features

- Patient enrollment and profile management
- Daily care task creation and tracking
- Task completion logging with notes
- Daily health assessments with vitals and metrics
- Caregiver assignment and reassignment

## Contract Functions

### Public Functions
- `enroll-patient`: Enroll a new elderly patient
- `create-care-task`: Create a care task for patient
- `complete-task`: Mark task as completed with notes
- `record-daily-assessment`: Record daily health assessment
- `reassign-caregiver`: Change assigned caregiver
- `discharge-patient`: Discharge patient from care

### Read-Only Functions
- `get-patient`: Retrieve patient information
- `get-care-task`: Get care task details
- `get-task-completion`: Get task completion record
- `get-daily-assessment`: Get daily assessment record
- `is-patient-active`: Check if patient is actively enrolled

## Assessment Metrics

- Vitals checking status
- Meals completed (0-4)
- Mobility score (0-10)
- Mood rating (0-10)

## Testing

Run tests with Clarinet:
```bash
clarinet test
```

## License

MIT License