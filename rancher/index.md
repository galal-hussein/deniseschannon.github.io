---
title: Rancher Documentation
layout: rancher-default

---

## Overview of Rancher
---

Rancher is an open source software platform that implements a purpose-built infrastructure for running containers in production. Docker containers, as an increasingly popular application workload, create new requirements in infrastructure services such as networking, storage, load balancer, security, service discovery, and resource management.

### Computing Resources

Rancher takes in raw computing resources from any public or private cloud in the form of Linux hosts. Each Linux host can be a virtual machine or a physical machine. Rancher does not expect more from each host than CPU, memory, local disk storage, and network connectivity. From Rancher's perspective, a VM instance from a cloud provider and a bare metal server hosted at a colo facility are indistinguishable.

### Key Features

Key product features of Rancher include: 

1. Cross-host networking. Rancher creates a private software defined network for each environment, allowing secure communication between containers across hosts and clouds.

2. Container load balancing. Rancher provides an integrated, elastic load balancing service to distribute traffic between containers or services. The load balancing service works across multiple clouds.

3. Storage management. Rancher supports live snapshot and backup of Docker volumes, enabling users to backup stateful containers and stateful services.

4.	Service discovery: Rancher implements a distributed DNS-based service discovery function with integrated health checking that allows containers to automatically register themselves as services, as well as services to dynamically discover each other over the network.

5.	Service upgrades: Rancher makes it easy for users to upgrade existing container services, by allowing service cloning and redirection of service requests.  This makes it possible to ensure services can be validated against their dependencies before live traffic is directed to the newly upgraded services. 

6.	Resource management: Rancher supports Docker Machine, a powerful tool for provisioning hosts directly from cloud providers. Rancher then monitors host resources and manages container deployment.

7. Multi-tenancy & user management: Rancher is designed for multiple users and allows organizations to collaborate throughout the application lifecycle. By connecting with existing directory services, Rancher allows users to create separate development, testing, and production environments and invite their peers to collaboratively manage resources and applications.

### Primary Consumption Interfaces

There are three primary ways for users to interact with Rancher:

1. Users can interact with Rancher through native Docker CLI or API. Rancher is not another orchestration or management layer that shields users from the native Docker experience. As Docker platform grows over time, a wrapper layer will likely be superseded by native Docker features. Rancher instead works in the background so that users can continue to use native Docker CLI and Docker Compose templates. Rancher uses Docker labels--a Docker 1.6 feature contributed by Rancher Labs--to pass additional information through the native Docker CLI.  Because Rancher supports native Docker CLI and API, third-party tools like Kubernetes work on Rancher automatically.
2. Users can interact with Rancher using a command-line tool called `rancher-compose`. The `rancher-compose` tool enables users to stand up multiple containers and services based on the Docker Compose templates on Rancher infrastructure. The `rancher-compose` tool supports the standard `docker-compose.yml` file format. An optional `rancher-compose.yml` file can be used to extend and overwrite service definitions in `docker-compose.yml`.
3. Users can interact with Rancher using the Rancher UI. Rancher UI is required for one-time configuration tasks such as setting up access control, managing environments, and adding Docker registries. Rancher UI additionally provides a simple and intuitive experience for managing infrastructure and services.

The following figure illustrates Rancher's major features, its ability to run any clouds, and the three primary ways to interact with Rancher.

<img src="{{site.baseurl}}/img/rancher/rancher_overview.png" width="800" alt="Rancher Overview">

### Outline of This Guide

It is easy to get Rancher up and running. If you have access to a Linux VM on your laptop or in a cloud, go to the [Quick Start Guide]({{site.baseurl}}/rancher/quick-start-guide/) to get started right away.

If you are ready to set up a production-grade Rancher installation, follow the instructions in the [Installing Rancher]({{site.baseurl}}/rancher/installing-rancher/installing-server/) to setup a Rancher server and add hosts into the Rancher installation.

Before you start using Rancher, make sure to read through the [Concepts]({{site.baseurl}}/rancher/concepts/) section to understand how Rancher works.

The Configuration section documents how you perform various one-time tasks after you complete installation of Rancher and start using Rancher.

The next three sections--[Using Rancher Through Native Docker CLI]({{site.baseurl}}/rancher/native-docker/), [Rancher Compose]({{site.baseurl}}/rancher/rancher-compose), and [Rancher UI]({{site.baseurl}}/rancher/rancher-ui)--covers three primary ways you can consume Rancher features.

The [Upgrading Rancher]({{site.baseurl}}/rancher/upgrading) section is essential if you run Rancher in production.

The [Contributing to Rancher]({{site.baseurl}}/rancher/contributing) section contains information on how you can participate in the Rancher open source community.

## Quick Start Guide
---

In this guide, we will create a simple Rancher install, which is a single host installation that runs everything on a single Linux machine.

### Prepare a Linux host

Provision a Linux host with 64-bit Ubuntu 14.04, which must have a kernel of 3.10+. You can use your laptop, a virtual machine, or a physical server. Please make sure the Linux host has at least **1GB** memory.

To install Docker on the server, follow these instructions, which are simplified from the [Docker](https://docs.docker.com/installation/ubuntulinux/) documentation. 

```bash
#Get the latest Docker package
$ wget -qO- https://get.docker.com/ | sh
# Verify that you have the latest version
$ sudo docker version
```

### Start Rancher Server

All you need is one command to launch Rancher server. After launching the container, we'll tail the logs to see when the server is up and running.

```bash
$ sudo docker run -d --restart=always -p 8080:8080 rancher/server
# Tail the logs to show Rancher
$ sudo docker logs -f containerid
```

It will take a couple of minutes for Rancher server to start up. When the logs show `.... Startup Succeeded, Listening on port 8080`, Rancher UI is up and running.

Our UI is exposed on port `8080`, so in order to view the UI, go to http://server_ip:8080. If you are running your browser on the same host running Rancher server, you will need to use the host’s real IP, like http://192.168.1.100:8080 and not http://localhost:8080 or http://127.0.0.1:8080.

> **Note:** Rancher will not have access control configured and your UI and API will be available to anyone who has access to your IP. We recommend configuring [access control]({{site.baseurl}}/rancher/configuration/access-control/).

### Add Hosts

For simplicity, we will add the same host running the Rancher server as a host in Rancher. In real production deployments, we recommend having dedicated hosts running Rancher server(s). 

To add a host, access the UI and click **Infrastructure**, which will immediately bring you to the **Hosts** page. Click on the **Add Host**. If access control is not configured, Rancher will prompt you to select an IP address. This IP address must be reachable from all the hosts that you will be adding. This is useful in installations where Rancher server will be exposed to the Internet through a NAT firewall or a load balancer. If your host has a private or local IP address like `192.168.*.*`, Rancher will print a warning asking you to make sure hosts can indeed reach the IP.

For now you can ignore these warnings as we will only add the Rancher server host itself. Click **Save**. You’ll be presented with a few options to add hosts from various cloud providers. Since we are adding the host that is running Rancher server, we'll click the **Custom** option. In the UI, Rancher will provide a command to use to add hosts.

```bash
$ sudo docker run -d --privileged -v /var/run/docker.sock:/var/run/docker.sock rancher/agent:v0.7.9 http://172.17.0.3:8080/v1/scripts/DB121CFBA836F9493653:1434085200000:2ZOwUMd6fIzz44efikGhBP1veo
```

Since we are adding a host that is running Rancher server, we need to edit the command and insert `-e CATTLE_AGENT_IP=<server_ip>` into the command, where `<server_ip>` is the IP address of the Rancher server host. 

In our example, `<server_ip>` is `172.17.0.3`, we will update the command to add in setting the environment variable.

```bash
$ sudo docker run -e CATTLE_AGENT_IP=172.17.0.3 -d --privileged -v /var/run/docker.sock:/var/run/docker.sock rancher/agent:v0.7.9 http://172.17.0.3:8080/v1/scripts/DB121CFBA836F9493653:1434085200000:2ZOwUMd6fIzz44efikGhBP1veo
```

Run this command in a shell terminal of the host that is running Rancher server. 

When you click **Close** on the Rancher UI, you will be directed back to the **Infrastructure** -> **Hosts** view. In a little bit, the host will automatically appear.

### Create a Container through UI

In the newly added host, click **+ Add Container**. Provide the container a name like “first_container”. You can just use our default settings and click **Create**. Rancher will start launching two containers on the host. One container is the **_first_container_** that we requested. The other container is a **_Network Agent_**, which is a system container created by Rancher to handle tasks such as cross-host networking, health checking, etc.

Regardless what IP address your host has, both the **_first_container_** and **_Network Agent_** will have IP addresses in the `10.42.*.*` range. Rancher has created this overlay network so containers can communicate with each other even if they reside on different hosts.

If you hover over the **_first_container_**, you will be able to perform management actions like stopping the container, viewing the logs, or accessing the container console.

### Create a Container through Native Docker CLI

Rancher will display any containers on the host even if the container is created outside of the UI. Create a container in the host's shell terminal.

```bash
$ docker run -it --name=second_container ubuntu:14.04.2
```

In the UI, you will see **_second_container_** pop up on your host! If you terminate the container by exiting the shell, the Rancher UI will immediately show the stopped state of the container.

Rancher reacts to events that happen out of the band and just does the right thing to reconcile its view of the world with reality. You can read more about using Rancher with the [native docker CLI]({{site.baseurl}}/rancher/native-docker/).

If you look at the IP address of the **_second_container_**, you will notice that it is not in `10.42.*.*` range. It instead has the usual IP address assigned by the Docker daemon. This is the expected behavior of creating a Docker container through the CLI. 

What if we want to create a Docker container through CLI and still give it an IP address from Rancher’s overlay network? All we need to do is add a label in the command. 

```bash
$ docker run -it --label io.rancher.container.network=true ubuntu:14.04.2
```

The label `io.rancher.container.network` enables us to pass a hint through the Docker command line so Rancher will set up the container to connect to the overlay network.

<!--Given Rancher’s ability to import existing containers automatically, you might wonder why you do not see the Rancher server container itself in the Rancher UI. To avoid confusion, Rancher does not automatically import server or agent containers created by Rancher.-->

### Create a Multi-Container Application

We have shown you how to create individual containers and connect them to a cross-host network. Most real-world applications, however, are made out of multiple services, with each service made up of multiple containers. A WordPress application, for example, could consist of the following services:

1. A load balancer. The load balancer redirects Internet traffic to the WordPress application.
2. A WordPress service consisting of two WordPress containers.
3. A database service consisting of one MySQL container.

The load balancer links to the WordPress service, and the WordPress service links to the MySQL service.

In this section, we will walk through how to create and deploy the WordPress application in Rancher.

From the Rancher UI, click the **Applications** tab, and click on the **Get Started** button to add your first service. 

You will immediately be able to add a service. First, we'll create a database service called _database_ and use the mysql image. In the **Advanced Options**, add the environment variable `MYSQL_ROOT_PASSWORD=pass1`. Click **Create**. You will be immediately brought to a stack page, which will contain all the services. After the service is created, click on **Start** in the service.

Next, click on the **Add Service** to add another service. We'll add a WordPress service and link to the mysql service. Let's use the name, _mywordpress_, and use the wordpress image. We'll move the slider to have the scale of the service be 2 containers. In the **Service Links**, add the _database_ service and provide the name _mysql_. Just like in Docker, Rancher will link the necessary environment variables in the WordPress image from the linked database when you select the name as _mysql_. Click **Create**. After the service is created, click on **Start** in the service and you will see 2 containers being launched for this service.

Finally, we'll create our load balancer. Click on the dropdown menu icon next to the **Add Service** button. Select **Add Load Balancer**. Provide a name like _wordpresslb_ and select pubilc port on the host that you'll use to access the wordpress application. Select the target and target port. The target will be _mywordpress_ service and set the target port as `80`. Click **Create**. After the load balancer is created, click on **Start** in the load balancer.

Our multi-service application is now complete! Find the IP of the host that the load balancer is on. Open a browser to the `host_IP:public_port` and you should see the wordpress application.

### Create a Multi-Container Application using Rancher Compose

In this section, we will show you how to create and deploy the same WordPress application we created in the previous section using a command-line tool called `rancher-compose`. 

The `rancher-compose` tool works just like the popular `docker-compose` tool. It takes in the same `docker-compose.yml` file and deploys the application on Rancher. You can specify additional attributes in a `rancher-compose.yml` file which extends and overwrites the `docker-compose.yml` file.

In the previous section, we created a Wordpress application with a load balancer. If you had created it in Rancher, you can download the files directly from our UI by selecting **Export Config** from the stack's dropdown menu. The `docker-compose.yml` and `rancher-compose.yml` files would look like this:

**docker-compose.yml**

```yaml
mywordpress:
tty: true
image: wordpress
links:
database: mysql
stdin_open: true
wordpresslb:
ports:
- 8090:80
tty: true
image: rancher/load-balancer-service
links:
mywordpress: mywordpress
stdin_open: true
database:
environment:
MYSQL_ROOT_PASSWORD: pass1
tty: true
image: mysql
stdin_open: true
```

**rancher-compose.yml**

```yaml
mywordpress:
scale: 2
wordpresslb:
scale: 1
load_balancer_config:
lb_cookie_stickiness_policy: null
description: null
name: wordpresslb config
app_cookie_stickiness_policy: null
health_check:
port: null
interval: 2000
unhealthy_threshold: 3
request_line: ''
healthy_threshold: 2
response_timeout: 2000
database:
scale: 1
```

Download the `rancher-compose` binary from Rancher UI, which is located on the upper right corner of the **Applications** -> **Stacks** page. We provide the ability to download the binaries for Windows, Mac, and Linux.

If order for services to be launched in Rancher using `rancher-compose`, you will need to set some variables in `rancher-compose`. You will need to create an [API Key]({{site.baseurl}}/rancher/configuration/api-keys/) in the Rancher UI. Click on the account icon and go to **Settings** -> **API & Keys**. Click on **Add API Key**. Save the username (access key) and password (secret key). Set up the environment variables needed for rancher-compose: `RANCHER_URL`, `RANCHER_ACCESS_KEY`, and `RANCHER_SECRET_KEY`.

```bash
# Set the url that Rancher is on
$ export RANCHER_URL=http://server_ip:8080/
# Set the access key, i.e. username
$ export RANCHER_ACCESS_KEY=<username_of_key>
# Set the secret key, i.e. password
$ export RANCHER_SECRET_KEY=<password_of_key>
```

Now, navigate to the directory where you saved `docker-compose.yml` and `rancher-compose.yml` and run the command.

```bash
$ rancher-compose -p NewWordpress up
```

In Rancher, a new stack will be created called **NewWordPress** with all of the services launched.

## Concepts
---

In this section, we introduce the key concepts in Rancher. You should be familiar with these concepts before attempting to use Rancher.

### Users

Users govern who has the access rights to view and manage Rancher resources within their Environment.  Rancher allows access for a single tenant by default. However, multi-user support can also be enabled.

See [access control]({{site.baseurl}}/rancher/configuration/access-control/) before you enable authentication.

### Environments

All hosts and any Rancher resources, such as containers, load balancers, and so on are created in and belong to an environment.  Access control permissions for viewing and managing these resources are then defined by the owner of the environment.  Rancher currently supports the capability for each user to manage and invite other users to their environment and allows for the ability to create multiple environments for different workloads.  For example, you may want to create a "dev" environment and a separate "production" environment with its own set of resources and limited user access for your application deployment.

Set up [Access control]({{site.baseurl}}/rancher/configuration/access-control/) before you [share environments]({{site.baseurl}}/rancher/configuration/environments/) with users. 

<a id="host"></a>

### Hosts

Hosts are the most basic unit of resource within Rancher and is represented as any Linux server, virtual or physical, with the following minimum requirements:

* Any modern Linux distribution that supports Docker 1.6+.
* Ability to communicate with a Rancher server via http or https through the pre-configured port. Default is 8080.
* Ability to be routed to any other hosts under the same environment to leverage Rancher's cross-host networking for Docker containers.

Rancher also supports Docker Machine and allows you to add your host via any of its supported drivers.

See [add your first host]({{site.baseurl}}/rancher/rancher-ui/infrastructure/hosts) before adding your first host to Rancher.

### Networking

Rancher supports cross-host container communication by implementing a simple and secure overlay network using IPsec tunneling.  To leverage this capability, a container launched through Rancher must select "Managed" for its network mode or if launched through Docker, provide an extra label "--label io.rancher.container.network=true".  Most of Rancher's network features, such as load balancer or DNS service, require the container to be in the managed network.

Under Rancher's network, a container will be assigned both a Docker bridge IP (172.17.0.0/16) and a Rancher managed IP (10.42.0.0/16) on the default docker0 bridge.  Containers within the same environment are then routable and reachable via the managed network.

**_Note:_** _The Rancher managed IP address will be not present in Docker meta-data and as such will not appear in the result of a Docker "inspect." This sometimes causes incompatibilities with certain tools that require a Docker bridge IP. We are already working with the Docker community to make sure a future version of Docker can handle overlay networks more cleanly._

### Service Discovery

Rancher adopts the standard Docker Compose terminology for services and defines a basic service as one or more containers created from the same Docker image.  Once a service (consumer) is linked to another service (producer) within the same stack, a DNS record mapped to each container instance is automatically created and discoverable by containers from the "consuming" service.  Other benefits of creating a service under Rancher include:

* Service HA - the ability to have Rancher automatically monitor container states and maintain a service's desired scale.
* Health Monitoring - the ability to set basic monitoring thresholds for container health.
* Add Load Balancers - the ability to add a simple load balancer for your services using HAProxy.
* Add External Services - the ability to add any-IP as a service to be discovered.
* Add Service Alias - the ability to add a DNS record for your services to be discovered.

For more information, see [adding services]({{site.baseurl}}/rancher/rancher-ui/applications/stacks/adding-services/), [adding load balancers]({{site.baseurl}}/rancher/rancher-ui/applications/stacks/adding-balancers/), [adding external services]({{site.baseurl}}/rancher/rancher-ui/applications/stacks/adding-external-services/) or [adding service alias]({{site.baseurl}}/rancher/rancher-ui/applications/stacks/adding-service-alias/).

### Load Balancer

Rancher implements a managed load balancer using HAProxy that can be manually scaled to multiple hosts.  A load balancer can be used to distribute network and application traffic to individual containers by directly adding them or "linked" to a basic service.  A basic service that is "linked" will have all its underlying containers automatically registered as load balancer targets by Rancher.

### Distributed DNS Service

Rancher implements a distributed DNS service by using its own light-weight DNS server coupled with a highly available control plane. Each healthy container is automatically added to the DNS service when linked to another service or added to a Service Alias. When queried by the service name, the DNS service returns a randomized list of IP addresses of the healthy containers implementing that service.

Because Rancher’s overlay networking provides each container with a distinct IP address, you do not need to deal with port mappings and do not need to handle situations like duplicated services listening on different ports. As a result, a simple DNS service is adequate for handling service discovery.

### Health Checks

Rancher implements a health monitoring system by running managed network agent’s across it’s hosts to co-ordinate the distributed health checking of containers and services. These network agents internally utilize HAProxy to validate the health status of your applications. When health checks are enabled either on an individual container or a service, each container is then monitored by up to three network agents running on hosts seperate to that containers parent host. The container is considered healthy if at least one HAProxy instance reports a “passed” health check.

> **Note:** The only exception to this model is when your environment contains a single host. In such instances the health checks will be performed by the same host.

Rancher handles network partitions and is more efficient than client-based health checks. By using HAProxy to perform health checks, Rancher enables users to specify the same health check policy across applications and load balancers.

For more information such as including example failure scenarios and how Rancher displays services, see [Health Checks]({{site.baseurl}}/rancher/concepts/health-checks/). You can also read more about setting up health checks by using [rancher-compose]({{site.baseurl}}/rancher/rancher-compose/rancher-services/#health-check-for-services) or in the [UI]({{site.baseurl}}/rancher/rancher-ui/applications/stacks/adding-services/#health-checks).

### Service HA

Rancher constantly monitors the state of your containers within a service and actively manages to ensure the desired scale of the service.  This can be triggered when there are fewer (or even more) healthy containers than the desired scale of your service, a host becomes unavailable, a container fails, or is unable to meet a health check.

### Service Upgrade

Rancher supports the notion of service upgrades by allowing users to either load balance or apply a service alias for a given service.  By leveraging either Rancher features, it creates a static destination for existing workloads that require that service.  Once this is established, the underlying service can be cloned from Rancher as a new service, validated through isolated testing, and added to either the load balancer or service alias when ready.  The existing service can be removed when obsolete. Subsequently, all the network or application traffic are automatically distributed to the new service.

### Rancher Compose

Rancher implements and ships a command-line tool called rancher-compose that is modeled after docker-compose. It takes in the same docker-compose.yml templates and deploys the Stacks onto Rancher. The rancher-compose tool additionally takes in a rancher-compose.yml file which extends docker-compose.yml to allow specifications of attributes such as scale, load balancing rules, health check policies, and external links not yet currently supported by docker-compose.

For more information, see [rancher-compose]({{site.baseurl}}/rancher/rancher-compose/).

### Stacks

A Rancher stack mirrors the same concept as a docker-compose project.  It represents a group of services that make up a typical application or workload.

<!--
```bash
rancher-compose up -p app1
```

This command deploys the docker-compose.yml template in the current directory into app1. All services in the same stack can link to each other through service discovery.
-->
### Container Scheduling

Rancher supports container scheduling policies that are modeled closely after Docker Swarm.  They include scheduling based on:

* port conflicts
* shared volumes
* host tagging
* shared network stack: --net=container:dependency
* strict and soft affinity/anti-affinity rules by using both env var (Swarm) and labels (Rancher)

In addition, Rancher supports scheduling service triggers that allow users to specify rules, such as on "host add" or "host label", to automatically scale services onto hosts with specific labels.

For more information on Container Scheduling and comparison matrix of Rancher's scheduling and Docker Swarm, see [rancher-compose]({{site.baseurl}}/rancher/rancher-compose/scheduling/) 

### Sidekicks

Rancher supports the colocation, scheduling, and lock step scaling of a set of services by allowing users to group these services by using the notion of sidekicks.  A service with one or more sidekicks is typically created to support shared volumes (i.e. `--volumes_from`) and networking (i.e. `--net=container`) between containers.

For more information, see [sidekicks with rancher-compose]({{site.baseurl}}/rancher/rancher-compose/#sidekicks).

### Metadata Services

Rancher offers data for both your services and containers. This data can be used to manage your running Docker instances in the form of a metadata service accessed directly through a HTTP based API.  These data can include static information when creating your Docker containers, Rancher Services, or runtime data such as discovery information about peer containers within the same service.

For more information, see [metadata service]({{site.baseurl}}/rancher/metadata-service/).


