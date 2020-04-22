# Contributing

When contributing to this repository, please open up a GitHub issue and assign it to yourself or claim an existing issue. 

Please note that the master branch is write protected so please make your commits in your own branch before making a pull request.

## Setting up Development Environment
1. Install XCode from the app store or from Apple's Developer website
2. Get developer credentials.
    - https://github.com/erwang01/ARrehab/wiki/Common-Issues

## Getting Started
1. Clone the repository `https://github.com/erwang01/ARrehab.git`
2. Create a branch related to your issue `git branch <branch_name>`
3. Checkout your branch `git checkout <branch_name>`

## Developing Minigames
1. Create a new branch off of the tiles branch.
    1. `git checkout tiles`
    2. `git branch <minigame-name>`
2. Develop
3. Create a Video Demo
    1. tag the commit used to create that demo: `git tag demo/<minigame-name>`
    2. Upload the video demo to Slack
4. Prep for a PR into tiles.
    1. Write a function to start the minigame. Note don't autoload the minigame on app launch as you might have done for the demo.
    2. Document your code!
    3. Create a pull request.

## Pull Request Process
1. Update the README.md with details of changes to the interface, this includes new environment variables, useful file locations and container parameters.
2. Submit a pull request with a description of what you did. Please tag the appropriate issue that was fixed by this pull request.
2. You may merge the Pull Request in once you have the sign-off of an admin, or if you do not have permission to do that, you may request the reviewer to merge it for you.
