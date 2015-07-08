# Github Releaser
Create new releases for your Github projects with this ~~crappy~~ bash script.

## Requirements
* [JSON.sh](https://github.com/dominictarr/JSON.sh)

## Configuration
* Put **JSON.sh** in the same folder as **githubreleaser.sh**.
* Create a personal access token (in personal settings).
* Add your username and token to the script.
* Do not forget to change the URL directly in the script (this will be fixed in the future):
```bash
URL=https://api.github.com/repos/[USERNAME HERE]/[REPO NAME HERE]/releases
```

## Usage
Type the following in the terminal
```bash
$ sh githubreleaser.sh
```
and just follow the instructions.

## Beware
Somewhat unstable. The script has some bugs (you can't add a tag description longer than ONE (1) word).
