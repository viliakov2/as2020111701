## This repository contains solution for the assessment task.

# Assessment 1.AWS

***

A: You have a client which is a webshop. They have a standard Magento setup with MySQL on a single VPC at their current provider and want to bring this to AWS.
The external software (Magento) is managed, developed and maintained by an external party.

1. Design an architecture which incorporates the following client needs. The clients know that his whole setup is going to evolve constantly. Include IaC templates (AWS CDK, Terraform, CloudFormation, other) for programmable infrastructure for your design.
  * Needs to be scalable and flexible
  * Needs to have low latency for SEO purposes
  * Needs to be cost effective


2. After releasing the new architecture, business takes on, and the client decides to add customer reviews.
  * Do you need to alter your architecture? And if so, how?


3. At some point, one of the customer employees is getting very good at creating vlogs, and the client wants to give customers the opportunity to upload videos with their reviews. They want to store the thumbnails and videos for later processing, and they want to show thumbnails of the videos underneath the product pages.
 * Alter your architecture to process and store these videos.


4. At some point, some clients uploaded non-compliant video's and which created a huge marketing issue. The client now wants to screen the uploaded video's before putting them online, but with minimal costs.
  * Alter your architecture to be able to screen and process these video's.


# Solution:

## The directory content

```
.
├── Readme.md
├── assets/
│   └── *.jpg
├── task1/
│   ├── Readme.md
│   └── *.tf
├── task2/
│   ├── Readme.md
│   └── *.tf
├── task3/
│   ├── lambda/
│   ├── Readme.md
│   └── *.tf
└── task4/
    ├── lambda/
    ├── Readme.md
    └── *.tf
```

* Readme.md -  Documentation in Markdown format, solution folder Readme-s contain Architecture diagram and the descriptions for the solution.
* taskX/ - folders containing documentation and IaC templates for solutions.
* *tf - files containing Terraform code to provision solution in AWS.
* assets/ - architecture diagrams in JPG format.
* lambda/ - Lambda function scripts and Zip archives.

## Solutions

* [Task1](task1/Readme.md)
* [Task2](task2/Readme.md)
* [Task3](task3/Readme.md)
* [Task4](task4/Readme.md)

The Readme-s contain architecture proposals and how to provision infrastructure for the solutions.

## Timing

1. **Task1**:

  - Timing:
    - Ramping up to Magento and its scalability options (30 minutes);
    - Designing architecture including diagram creation (60 minutes);
    - Developing and testing IaC templates for related AWS infrastructure (120 minutes);
    - Getting Magento package installed on EC2 and creating installation script (360 minutes);
    - Documenting the solution (120 minutes).
    - **Total**: 690 minutes
  - Notes:
    - Most of the time I spent trying to install Magento in multi-node mode and integrate it with related services and build an installation script to use within Autoscaling Group.

2. **Task2**:
  - Timing:
    - Designing architecture including diagram creation (120 minutes);
    - Developing and testing IaC templates for related AWS infrastructure (60 minutes);
    - Documenting the solution (60 minutes).
    - **Total**: 240 minutes
  - Notes:
    - I am not sure that the suggested solution is optimal from DB design point of view. The main idea was to offload the main Magento database and come up with an alternative from AWS managed services.

3. **Task3**:
  - Timing:
    - Learning the approaches on how to create thumbnails from videos: Lambda function, AWS Video Processing services (30 minutes)
    - Designing architecture including diagram creation (60 minutes);
    - Developing and testing IaC templates for related AWS infrastructure (160 minutes);
    - Documenting the solution (60 minutes).
    - **Total**: 310 minutes

4. **Task4**:
  - Timing:
    - Ramping up to AWS Step Functions (120 minutes)
    - Designing architecture including diagram creation (60 minutes)
    - Developing and testing IaC templates and Lambda/Step functions code (180 minutes);
    - Documenting the solution (30 minutes).
    - **Total**: 390 minutes

**Total**: 1630 minutes = ~27 hours
