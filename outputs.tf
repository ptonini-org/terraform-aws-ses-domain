output "this" {
  value = aws_ses_domain_identity.this
}

output "dkim" {
  value = aws_ses_domain_dkim.this
}

output "dns_records" {
  value = local.dns_records
}

output "policy_arn" {
  value = module.policy.this.arn
}