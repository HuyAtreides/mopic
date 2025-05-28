resource "aws_s3_bucket" "mopic_data" {
  bucket = "mopic-data"
}

resource "aws_s3_bucket" "mopic_config" {
  bucket = "mopic-config"
}

resource "aws_s3_object" "mopic_data_radarr" {
  bucket  = aws_s3_bucket.mopic_data.id
  key     = "/mopic/data/radarr/"
  content = ""
}

resource "aws_s3_object" "mopic_data_qbittorrent" {
  bucket  = aws_s3_bucket.mopic_data.id
  key     = "/mopic/data/qbittorrent/"
  content = ""
}

resource "aws_s3_object" "mopic_data_media" {
  bucket  = aws_s3_bucket.mopic_data.id
  key     = "/mopic/data/media/"
  content = ""
}


resource "aws_s3_object" "mopic_config_radarr" {
  bucket  = aws_s3_bucket.mopic_config.id
  key     = "/mopic/config/radarr/"
  content = ""
}

resource "aws_s3_object" "mopic_config_prowlarr" {
  bucket  = aws_s3_bucket.mopic_config.id
  key     = "/mopic/config/prowlarr/"
  content = ""
}

resource "aws_s3_object" "mopic_config_qbittorrent" {
  bucket  = aws_s3_bucket.mopic_config.id
  key     = "/mopic/config/qbittorrent/"
  content = ""
}

resource "aws_s3_object" "mopic_config_jellyfin" {
  bucket  = aws_s3_bucket.mopic_config.id
  key     = "/mopic/config/jellyfin/"
  content = ""
}
