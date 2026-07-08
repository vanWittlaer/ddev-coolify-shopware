# Staging environment settings (non-secret). See production.tfvars for the project-wide values.

staging = {
  web_image         = "ghcr.io/you/app/stage"
  web_image_tag     = "latest"
  web_domain        = "https://staging.example.com"
  app_env           = "stage"
  app_debug         = "1"
  monolog_log_level = "debug"

  enable_elasticsearch = true
  enable_mailpit       = true
  mailpit_domain       = "https://mailpit.staging.example.com"
  enable_backup        = true
  backup = {
    s3_backup_bucket = "myshop-backup"
    s3_backup_region = "hel1"
    s3_backup_domain = "https://hel1.your-objectstorage.com"
    s3_backup_path   = "staging"
  }

  mariadb_conf = "[mysqld]\ninnodb_buffer_pool_size=500M\n"
  redis_conf = {
    cache   = "appendonly no\nsave \"\"\nmaxmemory-policy volatile-lru\n"
    session = "appendonly yes\nmaxmemory-policy allkeys-lru\n"
  }

  s3 = {
    bucket_private = "myshop-private"
    bucket_public  = "myshop-public"
    region         = "hel1"
    endpoint       = "https://hel1.your-objectstorage.com"
    cdn_domain     = "https://hel1.your-objectstorage.com/myshop-public/staging/public"
  }
}
