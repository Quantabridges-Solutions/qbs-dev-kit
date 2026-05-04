output "api_url" {
  description = "API Gateway HTTP endpoint (use as VITE_API_URL)"
  value       = aws_apigatewayv2_stage.default.invoke_url
}

output "lambda_function_name" {
  description = "Lambda function name (use as LAMBDA_FUNCTION_NAME GitHub secret)"
  value       = aws_lambda_function.api.function_name
}

output "frontend_bucket" {
  description = "S3 bucket name for frontend (use as FRONTEND_S3_BUCKET GitHub secret)"
  value       = aws_s3_bucket.frontend.bucket
}

output "cloudfront_domain" {
  description = "CloudFront domain name (app URL)"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

output "cloudfront_id" {
  description = "CloudFront distribution ID (use as CLOUDFRONT_DISTRIBUTION_ID GitHub secret)"
  value       = aws_cloudfront_distribution.frontend.id
}
