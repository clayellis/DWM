# TODO

## General

- Add documentation
- Determine if `Task` should maintain its `displayOrder` or if that should just be on `TaskData` and is set by the `TaskManager`

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
    - List carousel view
    - TaskListCarousel


### v1.1

- Reminders
    - How to create them, store them, schedule them, delete them

