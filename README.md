# Grafana buildpack

This buildpack installs Grafana into a Scalingo app image.

## Usage

1. Create and initialize a new git repository:

   ```bash
   mkdir my-grafana
   cd my-grafana
   git init .
   ```

2. Create an app:

   ```bash
   scalingo create my-grafana
   ```

   This also creates a git-remote called `scalingo`:

   ```bash
   git remote -v
   scalingo    git@ssh.osc-fr1.scalingo.io:my-grafana.git (fetch)
   scalingo    git@ssh.osc-fr1.scalingo.io:my-grafana.git (push)
   ```

3. Attach a PostgreSQL addon:

   ```bash
   scalingo --app my-grafana addons-add postgresql postgresql-starter-256
   ```

4. Instruct the platform to use this buildpack:

   ```bash
    scalingo --app my-grafana env-set BUILDPACK_URL="https://github.com/Scalingo/grafana-buildpack"
    ```

5. Set a few environment variables: **Please adjust the values**

   ```bash
   scalingo --app my-grafana env-set GF_PATHS_PLUGINS="/app/plugins"
   scalingo --app my-grafana env-set GF_SECURITY_ADMIN_USER="admin"
   scalingo --app my-grafana env-set GF_SECURITY_ADMIN_PASSWORD="secret"
   scalingo --app my-grafana env-set GF_SERVER_HTTP_PORT="\$PORT"
   scalingo --app my-grafana env-set GF_SERVER_ROOT_URL="https://my-grafana.osc-fr1.scalingo.io"
   ```

6. Create a new `GF_DATABASE_URL` environment var. It must be a copy of the one
   given by the platform and named `SCALINGO_POSTGRESQL_URL`, **except that
   `ssl_mode` must be set to `require` instead of `prefer`**.

7. (optional) Specify the Grafana version to deploy:

   ```bash
   scalingo --app my-grafana env-set GRAFANA_VERSION="11.0.0"
   ```

8. (optional) Add some plugins using the `GRAFANA_PLUGINS` environment var:

   ```bash
   scalingo --app my-grafana env-set GRAFANA_PLUGINS="esnet-arcdiagram-panel"
   ```

9. (optional) Scale to a L container:

   ```bash
   scalingo --app my-grafana scale web:1:L
   ```

10. Create an empty commit in your repo:

   ```bash
   git commit --allow-empty -m "First deployment"
   ```

11. Deploy:

   ```bash
   git push scalingo main
   ```

### Environment

The following environment variables are available for you to tweak your
deployment:

#### `GRAFANA_PLUGINS`

List of Grafana plugins to install.\
Defaults to being unset.

#### `GRAFANA_VERSION`

The version of Grafana you want to deploy.\
Defaults to `GRAFANA_DEFAULT_VERSION`
