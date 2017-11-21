# TODO

## General

- Add documentation
- Determine what's allowed
    - Tasks can have the same name
    - Tasks can have the same name if they are in different lists
    - Tasks cannot have the same name

## Services

- `TaskListManager`? (I'm not convinced that we need one, but the abstraction would be nice)
    - Initialized with a `TaskFrequency`
    - Contains a `TaskManager`
    - Manages the list reminder
    - Manages the custom start times (really only for `weekly` (beginning of week))
    - The order of tasks (v2, add ability to reorder)

- Determine a good error handling strategy

- Test throwing errors

- Make wording consistent
    - delete vs remove
    - insert vs store
    - "all", "records", "noun(s)" vs retrieve

## Views
    - AppCoordinator
    - Task list carousel collection view (centered cells)
    - Task list (style)


### v1.1

- Reminders
    - How to create them, store them, schedule them, delete them


- Add some confetti when tasks are completed. Add some fireworks when task lists are completed. In increasing intensity (daily, weekly, monthly)
