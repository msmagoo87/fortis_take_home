#!/usr/bin/env python
"""A script to get all EC2 instances, grouped by AMI image ID,
with details about the image. Prints out a JSON object with the image ID as the key.
AWS credentials must be configured in the environment when running the script.
"""

import boto3
import json


def get_instances(ec2, NextToken=None):
    """Get all ec2 instances from a given ec2 client object and pagenate using
    recursion.

    Args:
        ec2 (boto3.client): Boto3 client object for accessing ec2 resources.
        NextToken (bool, optional): A marker token for pagenation. Defaults to None.

    Returns:
        list: A list of ec2 instances.
    """
    if NextToken:
        resp = ec2.describe_instances(NextToken=NextToken)
    else:
        resp = ec2.describe_instances()

    if "NextToken" in resp:
        # If there is a token in the response, return the list of instances and
        # append a recursive call to this same function to get the next set of instances
        return [
            instance for r in resp["Reservations"] for instance in r["Instances"]
        ] + get_instances(ec2, resp["NextToken"])
    else:
        return [instance for r in resp["Reservations"] for instance in r["Instances"]]


def main():
    data = {}
    ec2 = boto3.client("ec2")  # Create a client object for the EC2 service
    # Loop through each instance in the response to construct the output
    for instance in get_instances(ec2):
        # Get the image details from the EC2 service
        img_res = ec2.describe_images(ImageIds=[instance["ImageId"]])
        # Check if the image is already a key in the dictionary.
        # If it is, we must construct a new entry in the dictionary.
        # Otherwise we can just append the instance to the existing entry.
        if instance["ImageId"] not in data:
            if len(img_res["Images"]) > 0:
                img = img_res["Images"][0]
            else:
                img = None
            data[instance["ImageId"]] = {
                "ImageDescription": img["Description"] if img else None,
                "ImageName": img["Name"] if img else None,
                "ImageLocation": img["ImageLocation"] if img else None,
                "OwnerId": img["OwnerId"] if img else None,
                "InstanceIds": [instance["InstanceId"]],
            }
        else:
            data[instance["ImageId"]]["InstanceIds"].append(instance["InstanceId"])

    print(json.dumps(data, indent=2))


if __name__ == "__main__":
    main()
