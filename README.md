<h1>
	<a href="https://github.com/qjack001/bash-template?=new">
		<img src="logo.svg" width="170.13" height="24" alt="template.sh logo">
	</a>
</h1>

[ [How to use](#how-to-use) ][ [Installing your CLI](#installing-your-cli) ][ [Contributing](#contributing) ][ [Attribution](#attribution) ][ [Examples](#examples) ]

<br>

A template file for creating simple command-line-interfaces. Includes commonly needed functions, such as coloring text and getting input, as well as hard-to-implement features, like a keyboard-navigatable menu.

### How to use

To get started, clone this repo and open the [`template.sh`](template.sh) file in a text editor. Fill-in your CLI's information (marked by `<angle brackets>`), and add your functions to the file — see the default [`no_args`](template.sh#L45) function for an example of the "library" in-use. Add your function to [`handel_input`](template.sh#L14)'s list of commands, and test it out:

```bash
sh template.sh <your-command-name>
```



Rename the template file to `<your-program-name>.sh` and push your changes to Github (or any other git host). Find the URL to the raw copy of the script and replace `source_url` with it. Push the changes again, and then try fetching it by running:

```bash
sh <your-program-name>.sh update
```

When it prompts you to install the script, choose "no" for now. **Important:** make sure you've commited all your changes before running the `update` command, as it will overwrite your `<your-program-name>.sh` file (if you are in your repo's directory).

### Installing your CLI

To install it globally (currently moves it to `/usr/local/bin/`), run:

```bash
sh <your-program-name>.sh install
```

**Important:** make sure you have commited all your changes before running the `install` command, as it will _move_ the script not copy (thus re-moving it from your repo).

Alternatively, if you do not have access or don't want to install it there, simply add an alias to your `.bash_profile` or `.bashrc` (_and don't forget to `source` them after!_):

```bash
alias <your-program-name>="sh ~/path/to/<your-program-name>.sh"
```

Now you should be able to run the program from any directory.

```bash
<your-program-name> --version
```

### Contributing

Please feel free to open an issue or pull request if you notice any bugs. If you find that there is anything missing that you commonly use, please add it.

### Attribution

If you would like to provide attribution, you can do so by linking to this repository (https://github.com/qjack001/bash-template), but it is not required.

### Examples

Projects which use this template:

- [`todo`](https://github.com/qjack001/todo) — A simple todo-list app (doesn't use the template verbatim, but does use most of it).
- [`jit`](https://github.com/qjack001/jit) — A `git` replacment that's more like Github Desktop (doesn't use the template at all, but rather the template was made based on how I did things there).
