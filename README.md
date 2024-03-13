# Creating customized Docker images for Piston

[Piston][] is a code execution engine that sandboxes code in many
different languages.

Unfortunately, Piston does not have a (working!) declarative format for
specifying:
 - which packages to install by default
 - what compiler flags should be used

So it requires some **manual** customization if you want to create
a ready-to-deploy Docker image with _just_ the packages and
customizations that you need.

## How to create a custom Piston image

First, spin up a Piston container. Use the `docker-compose.yml` provided
here to use the appropriate settings:

    docker compose up -d

### Install packages

Make sure you have the [Piston CLI][] cloned somewhere on your computer.
Use their instructions to set it up.

Now, use the Piston CLI to install desired base packages. For example:

    node cli ppman install gcc=10.2.0
    node cli ppman install python=3.12.0
    node cli ppman install rust=1.68.2

Note, this will copy files to a bind mount (should be
`./data/piston/packages`).

Now you're ready to build and tag the `packages-only` image!

```sh
docker build . --target packages-only --tag piston:packages-only
```

> [!NOTE]
> The Docker build context will be several GiBs. This is normal, albeit,
> unfortunate. Just be patient!
>
>     => [internal] load build context     25.1s
>     => => transferring context: 3.55GB   24.8s

Once the `packages-only` image is built, you may bring down the original
Piston container, as it is no longer needed:

    docker compose down

## Now what

I suggest use use the _tagged_ version of the Docker image that you just
created in your `docker-compose.yml`. You can also push your custom
image to the [GitHub Container Registry][ghcr] and pull the image from
where ever you want to deploy your custom version of Piston.

Here is an example of a `docker-compose.yml` that I use in production
application (sort of):

```yml
version: '3'
services:
  webapp:
    build: ./webapp
    restart: always
    depends_on:
      - piston
    ports:
      - '3000:3000'

  piston:
    # I tagged and pushed the image to ghcr. No need to build it again!
    image: ghcr.io/eddieantonio/piston:20231101-with-customizations
    restart: always
    tmpfs:
        - /piston/jobs:exec,uid=1000,gid=1000,mode=711
        - /tmp:exec
```

[Piston]: https://github.com/engineer-man/piston
[Piston CLI]: https://github.com/engineer-man/piston?tab=readme-ov-file#after-system-dependencies-are-installed-clone-this-repository
[ghcr]: https://github.com/features/packages
