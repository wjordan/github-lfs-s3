# Git LFS server for GitHub backed by S3

[![Build Status](https://travis-ci.org/wjordan/github-lfs-s3.svg?branch=master)](https://travis-ci.org/wjordan/github-lfs-s3)


A lightweight [Git LFS](https://git-lfs.github.com/) server for public GitHub repositories that stores files in an S3 bucket, allows public downloads, and authenticates uploads based on the GitHub user's write access to the repository.

The server provides public URLs for downloads, and generates pre-signed URLs for uploads after verifying the user has write access to the GitHub repository. All data goes from the Git LFS client to S3 directly, optionally using [transfer acceleration](https://docs.aws.amazon.com/AmazonS3/latest/dev/transfer-acceleration.html) for best performance.

## Installation

``` ruby
gem 'github-lfs-s3'
```

## Configuration

### Git Setup

* Install the Git LFS client according to the [Getting Started](https://git-lfs.github.com/) guide
* Configure the client to use this server with an `[lfs]` entry in a `.gitconfig` file in the repository root:

``` git
[lfs]
    url = "http://localhost:4567"
```

* Configure Git LFS to track some file patterns, e.g.:
```bash
git lfs track "*.png"
```

* Push your repository to GitHub, and the tracked files will be separately pushed to S3.

## Running

`github-lfs-s3` runs a basic Sinatra server, configure by a couple environment variables:

* `S3_BUCKET` - name of the S3 bucket where LFS objects will be stored
* `GITHUB_REPO` - name of the GitHub repository used to verify the GitHub user's write access.

``` bash
S3_BUCKET=my_test_bucket \
  GITHUB_REPO=wjordan/github-lfs-s3 \
  bundle exec github-lfs-s3
```
