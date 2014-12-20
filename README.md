vagrant-docker
==============

----------
PROJECT DESCRIPTION
----------

This project helps you manage your [docker](https://www.docker.com/whatisdocker/ "What it docker?") containers with a small footprint.

----------
Personal requirements
----------

It is built on top of [Virtualbox](https://www.virtualbox.org) and [Vagrant](http://www.vagrantup.com/downloads.html), therefore you should understand what both does, before you try to use this tool here. Also you should known how to create a [Dockerfile](https://docs.docker.com/reference/builder/).

----------
INSTALLATION
----------

- Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads "Virtualbox download page")

- Install [Vagrant](http://www.vagrantup.com/downloads.html "Vagrant download page") (Homebrew variant was not tested)

- Mac User: You need to install at least the command line tools. See more [here](http://railsapps.github.io/xcode-command-line-tools.html).

- Open your command line and run the following commands to install all required plugins (Terminal on Mac OS X/ CMD.exe on Windows)
- ``vagrant plugin install vagrant-hostmanager vagrant-vbguest nugrant``

- [Download](/reinblau/vagrant-docker/archive/master.zip) this project into your local machine and rename the unzipped file to *vagrant-docker*

- Copy [projects.txt.dist](projects.txt.dist) to projects.txt

- (Optional) Copy [.vagrantuser.dist](.vagrantuser.dist) to .vagrantuser. Change the values for your needs. (Ex. the vm-name, IP)

- Open your command line and navigate to the *vagrant-docker* directory.

- Run the command ``vagrant up`` and drink a coffee or something.

- Run the command ``vagrant provision``to update your local host file.

- Open your browser and enter *phpmyadmin.dev*.

- In case you do not see phpMyAdmin, something simalar like this [demopage](http://demo.phpmyadmin.net/master-config/), then you forget one step or something has changed in the meantime.


----------
Add your own Project
----------

In this project you find a directory called [dockerfiles/](dockerfiles/). This is the place where you store your dockerfiles in the following structure:

```
dockerfiles/
dockerfiles/private/
dockerfiles/private/myservice/run.sh
dockerfiles/private/myproject1/run.sh
dockerfiles/private/myproject2/run.sh
dockerfiles/company/
dockerfiles/company/companyservice/run.sh
dockerfiles/company/companyproject1/run.sh
dockerfiles/company/companyproject2/run.sh
```

After vagrant runs for the first time a directory will be filled with services from https://github.com/reinblau/dockerfiles.

Every project/service needs at least one shell-script called run.sh. This file is used to start your project (container) while vagrant starts the shell provisioner.
This means when you run the command ``vagrant up`` or ``vagrant reload`` or simple ``vagrant provision``.

To detect an error the script should exit with a none-0 exit code in case of an error. To reuse another service from [dockerfiles/](dockerfiles/) you can call
``rbrequire --project=directoryname`` before you start your container. Take a look at https://github.com/reinblau/dockerfiles/tree/master/drupal_boilerplate to see an example of it.
As you’ll see we use [crane](https://github.com/michaelsauter/crane) to build images or start a container. You can do that as well!


----------
Updates
----------

The shell provisioner provides a update mechanism to update this project, the OS, all the [dockerfiles/](dockerfiles/) which contains a git-repository, and all projects which have a crane.yml file.
  The container will then be stopped and removed to start the new container from the fresh docker image.

  - By default the shell provisioner will not update the system etc automatically, todo this
  change the value of autoupdate to true in your *.vagrantuser*

  - To update the system manually: Log in to the VM via ``vagrant ssh`` and run the command ``rbupdate``

To avoid the update of the dockerfiles or a docker image, create a file blacklist.txt and enter the directory names of every "namespace" or project. Example:
  ```
  public
  custom
  myproject
  ```

----------
Hosts file
----------

Our shell provisioner reads the VIRTUAL_HOST environment variable (provided for the [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) container) from all projects and creates a file called vhosts.txt. The vagrant plugin vagrant-hostmanager use this text file and updates your hosts file.
