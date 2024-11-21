# PLEASE READ

## Moving forward with Git and other things
When working on the project, the main branch should not be touched to ensure that faulty changes are not pushed before testing or changes are made without prior knowledge to the team. Whenever any updates are pushed to main, the group should know about the push to make sure they are on board with the changes.

## Git Branching
Since we don't want to overstep on other files or push faulty changes, we need to have multiple branches to keep track of development and testing. Therefore, we can split the branches into 2 main sections:

- Development
- Testing

The development branch will be the main area we will work on, pushing commits regularly and merging with others. If necessary, branches can be split from the main development branch to have independent areas, but generally all files to build the RISC-V should be here first.

The testing branch will be the area for working on testbenches and further changes for improvement. This will mainly consist of testbenches written for the development branch, but the testing branch will push commits with comments for clarity, detail and revision. I will be working on this branch most of the time, so I will update you on any specific changes/comments that might be relevant. When making revisions, **all changes should be made in the development branch first** before merging with the testing branch to ensure the development branch is always up to date for others.

## Git Tags
Tags are not necessary but useful for monitoring changes in main. Whenever a change in main is pushed, it should be tagged according to the size of the push (e.g. v.0.0 -> v.1.0 for a major push, v.0.0 -> v.0.1 for a minor push) so we keep track of what tag we are on and update accordingly.

## Git Rebasing
I'll refer to this StackOverflow post on why you would use rebasing.

```
Rebase is most useful when pushing a single commit or a small number of commits developed in a short time frame (hours or minutes).

Before pushing to a shared server, one must first pull the commits made to the origin's HEAD in the meantime—failing to do so would create a non-fast-forward push. In doing so, one can choose between a merge (git pull) or a rebase (git pull --rebase) operation. The merge option, while technically more appealing, creates an additional merge commit. For a small commit, the appearance of two commits per change actually makes the history less readable because the merge operation distracts from the commit's message.

In a typical shared development tree, every developer ends up pushing to a shared branch by doing some variation of git pull; <resolve conflicts>; git push. If they are using git pull without --rebase, what happens is that almost every commit ends up being accompanied by a merge commit, even though no parallel development was really going on. This creates an intertwined history from what is in reality a linear sequence of commits. For this reason, git pull --rebase is a better option for small changes resulting from short development, while a merge is reserved for integration of long-lived feature branches.

All this applies to rebasing local commits, or rebasing a short-lived feature branch shared by closely connected coworkers (sitting in the same room). Once a commit is pushed to a branch regularly followed by by others, it should never be rebased.

```