# TerraformAWS - Learning Library

This repository is my personal Terraform and AWS learning library. It contains comprehensive reference materials, examples, commands, and best practices for quick reference and hands-on practice.

## 📚 Repository Structure

### `/terraform-basics/`
Core Terraform concepts and fundamentals
- **terraform-commands.txt** - Complete command reference with examples
- **terraform-configuration.txt** - Configuration syntax, variables, outputs, and functions

### `/aws-services/`
AWS service overviews and CLI commands
- **aws-services-overview.txt** - Comprehensive guide to AWS services used with Terraform
- **aws-cli-commands.txt** - Essential AWS CLI commands for daily use

### `/examples/`
Practical Terraform code examples
- **terraform-aws-examples.txt** - Real-world infrastructure code examples:
  - EC2 instances
  - VPC with public/private subnets
  - S3 buckets with security
  - Load balancers and auto-scaling
  - RDS databases
  - Lambda functions
  - DynamoDB tables
  - CloudWatch monitoring

### `/tips-and-tricks/`
Best practices and optimization techniques
- **terraform-aws-tips.txt** - Expert tips covering:
  - Terraform best practices
  - Common patterns
  - AWS-specific optimization
  - Troubleshooting guide
  - Performance optimization
  - Cost optimization
  - CI/CD integration

### `/quick-reference/`
Quick lookup guides and cheat sheets
- **terraform-cheat-sheet.txt** - Quick command and syntax reference
- **aws-resources-reference.txt** - AWS Terraform resource types catalog

### `/pdf-docs/`
Placeholder for PDF documentation
- **README.txt** - Guide for creating visual PDF documentation

## 🚀 Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/maruftak/TerraformAWS.git
   cd TerraformAWS
   ```

2. Browse the topic you want to learn:
   - New to Terraform? Start with `/terraform-basics/`
   - Need a command? Check `/quick-reference/`
   - Looking for examples? See `/examples/`
   - Want best practices? Read `/tips-and-tricks/`

3. Use your favorite text editor or viewer to read the files

## 📖 How to Use This Library

- **For Learning**: Read through files sequentially in each directory
- **For Reference**: Use quick-reference guides for fast lookups
- **For Practice**: Copy examples and modify them for your projects
- **For Troubleshooting**: Consult tips-and-tricks for common issues

## 🎯 Topics Covered

### Terraform
- Commands and CLI usage
- Configuration syntax (HCL)
- Variables, outputs, and locals
- Modules and composition
- State management
- Workspaces
- Functions and expressions
- Dynamic blocks
- Meta-arguments

### AWS Services
- Compute (EC2, Lambda, ECS, EKS)
- Storage (S3, EBS, EFS)
- Networking (VPC, ALB, NLB, Route53)
- Databases (RDS, DynamoDB, ElastiCache)
- Security (IAM, KMS, Secrets Manager)
- Monitoring (CloudWatch, CloudTrail)
- Messaging (SNS, SQS, EventBridge)
- And many more...

## 💡 Best Practices Highlighted

- Remote state management
- Security hardening
- Cost optimization
- High availability patterns
- Disaster recovery
- CI/CD integration
- Testing strategies
- Documentation standards

## 🔧 Prerequisites

To use the examples in this library, you should have:
- Terraform installed (v1.0+)
- AWS CLI configured
- AWS account with appropriate permissions
- Basic understanding of cloud concepts

## 📝 File Format

All learning materials are in **plain text (.txt)** format for:
- Easy viewing in any text editor
- Simple version control with git
- Fast searching with grep/find
- No special software required
- Universal compatibility

## 🤝 Contributing

This is a personal learning repository, but suggestions are welcome:
- Found an error? Open an issue
- Have a better example? Suggest an improvement
- Missing a topic? Request it in issues

## 📜 License

See the [LICENSE](LICENSE) file for details.

## 🔗 Useful Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/index.html)

## 📧 Contact

For questions or suggestions, please open an issue in this repository.

---

**Note**: This is a learning repository. Examples are for educational purposes. Always review and test configurations before using in production environments.
