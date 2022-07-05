# encoding: utf-8

title 'Website Bucket'

bucket_name = input('bucket_name')

describe aws_s3_bucket(bucket_name: bucket_name) do
  it { should exist }
  it { should be_public }
end
