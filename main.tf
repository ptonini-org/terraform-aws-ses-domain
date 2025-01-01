locals {
  dns_records = merge({ for i, v in aws_ses_domain_dkim.this.dkim_tokens : "dkim-${i}" => {
    type    = "CNAME"
    name    = "${v}._domainkey.${aws_ses_domain_dkim.this.domain}"
    records = ["${v}.dkim.amazonses.com"]
    } }, { domain = {
    type    = "TXT"
    name    = "_amazonses.${aws_ses_domain_identity.this.domain}"
    records = [aws_ses_domain_identity.this.verification_token]
  } })
}

resource "aws_ses_domain_identity" "this" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.this.domain
}

module "policy" {
  source  = "app.terraform.io/ptonini-org/iam-policy/aws"
  version = "~> 1.0.0"
  name    = "ses-send-mail-from-${var.domain}"
  statement = [{
    effect    = "Allow"
    actions   = ["ses:SendRawEmail"]
    resources = [aws_ses_domain_identity.this.arn]
  }]
}

module "dns_records" {
  source   = "app.terraform.io/ptonini-org/route53-record/aws"
  version  = "~> 1.0.0"
  for_each = var.zone_id == null ? {} : local.dns_records
  zone_id  = var.zone_id
  name     = each.value["name"]
  type     = each.value["type"]
  records  = each.value["records"]
}

resource "aws_ses_email_identity" "this" {
  for_each = var.email_identities
  email    = each.value
}
