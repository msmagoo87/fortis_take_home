#!/usr/bin/env python
"""A script to get all EC2 instances, grouped by AMI image ID,
with details about the image. Prints out a JSON object with the image ID as the key.
AWS credentials must be configured in the environment when running the script.
"""

import boto3
import json


def get_instances(ec2, NextToken=None) -> list:
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


def get_images(ec2, NextToken=None) -> dict:
    """Get all images with a given ec2 client object and pagenate using recursion.

    Args:
        ec2 (boto3.client): Boto3 client object for accessing ec2 resources.
        NextToken (bool, optional): A marker token for pagenation. Defaults to None.

    Returns:
        dict: A dictionary of AMI image details keyed on their IDs.
    """
    output = {}
    if NextToken:
        resp = ec2.describe_images(NextToken=NextToken)
    else:
        resp = ec2.describe_images()

    for img in resp["Images"]:
        # Loop through each image in the response to construct the output
        output[img["ImageId"]] = {
            "ImageDescription": img.get("Description"),
            "ImageName": img.get("Name"),
            "ImageLocation": img.get("ImageLocation"),
            "OwnerId": img.get("OwnerId"),
            "InstanceIds": [],
        }
    if "NextToken" in resp:
        # If there is a token in the response, return the dictionary of images and
        # append a recursive call to this same function to get the next set of images
        return output | get_instances(ec2, resp["NextToken"])
    else:
        return output


def main():
    data = {}
    ec2 = boto3.client("ec2")  # Create a client object for the EC2 service
    # Get a list of all the images so we don't have to make a call for each instance
    images = get_images(ec2)
    # Loop through each instance in the response to construct the output
    for instance in get_instances(ec2):
        if instance["ImageId"] not in data:
            # If the image ID is not in the dictionary yet, create a new entry
            # If the image ID is not found in the images dictionary, use null values
            data[instance["ImageId"]] = images.get(instance["ImageId"], {
                "ImageDescription": None,
                "ImageName": None,
                "ImageLocation": None,
                "OwnerId": None,
                "InstanceIds": [],
            })
        # Append the instance ID to the list of instance IDs for the image ID
        data[instance["ImageId"]]["InstanceIds"].append(instance["InstanceId"])

    print(json.dumps(data, indent=2))


if __name__ == "__main__":
    main()
