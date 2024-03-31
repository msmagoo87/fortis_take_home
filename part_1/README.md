# Part 1

The first part of the challenge is to create a script that will get all of the ec2 instances in a region, grouped by AMI ID, and construct output that adds details of the AMI with a list of the instances using that AMI. The result is a python script using a Conda environment. The conda environment is set up to use Python version 3.11 and the latest version of boto3.


## Usage

The environment to run this script can be setup via [Anaconda](https://anaconda.org/). 
Set up the evironment by doing the following from this directory:
```bash
conda env create -f environment.yaml
conda activate fortis_part_1
```
This will get you in to the conda environment which has all required dependencies installed.
This script requires that you have the aws session set up in the environment. I personally use [aws-vault](https://github.com/99designs/aws-vault) for this, but as long as the required access and secrets keys are in the environment, you're good to go. 
Then simply run the script:
```bash
./main.py 
```

## Sample Output

This script outputs a formatted JSON object like the below sample:

```json
{ 
    "ami-0d5f069b7a75be450": { 
        "ImageDescription": "ubuntu-1804-encrypted-amd64-20190403", 
        "ImageName": "ubuntu-1804-encrypted-amd64-20190403", 
        "ImageLocation": "12345678901/ubuntu-1804-encrypted-amd64-20190403",
        "OwnerId": "12345678901", 
        "InstanceIds": [ 
            "i-04f241953cfe0066d", 
            "i-02439968b22cb6b8d"  
        ] 
    }, 
    "ami-c0464db9": {
        "ImageDescription": "Canonical, Ubuntu, 16.10, amd64 yakkety image build",
        "ImageName": "ubuntu/images/hvm-ssd/ubuntu-yakkety-16.10-amd64-server-2",
        "ImageLocation": "099720109477/ubuntu/images/hvm-ssd/ubuntu-yakkety-16.",
        "OwnerId": "099720109477", 
        "InstanceIds": [ 
            "i-063e73a673eda7892"
        ]
    },
    "ami-1df0ac78": {
        "ImageDescription": null,
        "ImageName": null,
        "ImageLocation": null,
        "OwnerId": null,
        "InstanceIds": [
            "i-19be2ba7",
            "i-6a7a49dd"
        ]
    }
} 
```
