package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/packer"
	"github.com/gruntwork-io/terratest/modules/retry"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/test-structure"
)

// The test is broken into "stages" so you can skip stages by setting environment variables (e.g., skip stage
// "deploy_initial" by setting the environment variable "SKIP_deploy_initial=true"), which speeds up iteration when
// running this test over and over again locally.
func TestTerraformPackerExample(t *testing.T) {
	t.Parallel()

	// Use eu-west-1 for now, but in future we should pick a random AWS region
	awsRegion := "eu-west-1"

	// The folder where we have our Terraform code
	workingDir := "../"

	// Build the AMI for the web app
	test_structure.RunTestStage(t, "build_ami", func() {
		buildAmi(t, awsRegion, workingDir)
	})

	// At the end of the test, delete the AMI
	defer test_structure.RunTestStage(t, "cleanup_ami", func() {
		deleteAmi(t, awsRegion, workingDir)
	})

	// At the end of the test, undeploy the web app using Terraform
	defer test_structure.RunTestStage(t, "cleanup_terraform", func() {
		undeployUsingTerraform(t, workingDir)
	})

	// Deploy the web app using Terraform
	test_structure.RunTestStage(t, "deploy_terraform", func() {
		deployUsingTerraform(t, awsRegion, workingDir)
	})

	// Validate that the ASG deployed and is responding to HTTP requests
	test_structure.RunTestStage(t, "validate", func() {
		validateAsgRunningWebServer(t, workingDir)
	})
}

// Build the AMI
func buildAmi(t *testing.T, awsRegion string, workingDir string) {
	packerOptions := &packer.Options{
		// The path to where the Packer template is located
		Template: "../packer/aws/app-server.json",
	}

	// Save the Packer Options so future test stages can use them
	test_structure.SavePackerOptions(t, workingDir, packerOptions)

	// Build the AMI
	amiId := packer.BuildAmi(t, packerOptions)

	// Save the AMI ID so future test stages can use them
	test_structure.SaveAmiId(t, workingDir, amiId)
}

// Delete the AMI
func deleteAmi(t *testing.T, awsRegion string, workingDir string) {
	// Load the AMI ID and Packer Options saved by the earlier build_ami stage
	amiId := test_structure.LoadAmiId(t, workingDir)

	aws.DeleteAmi(t, awsRegion, amiId)
}

// Deploy the terraform-packer-example using Terraform
func deployUsingTerraform(t *testing.T, awsRegion string, workingDir string) {
	// Load the AMI ID saved by the earlier build_ami stage
	amiId := test_structure.LoadAmiId(t, workingDir)

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: workingDir,

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"ami": amiId,
		},
	}

	// Save the Terraform Options struct, instance name, and instance text so future test stages can use it
	test_structure.SaveTerraformOptions(t, workingDir, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)
}

// Undeploy the terraform-packer-example using Terraform
func undeployUsingTerraform(t *testing.T, workingDir string) {
	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	terraform.Destroy(t, terraformOptions)
}

// Validate the ASG has been deployed and is working
func validateAsgRunningWebServer(t *testing.T, workingDir string) {
	// Load the Terraform Options saved by the earlier deploy_terraform stage
	terraformOptions := test_structure.LoadTerraformOptions(t, workingDir)

	// Run `terraform output` to get the value of an output variable
	url := terraform.Output(t, terraformOptions, "url")

	// It can take a few minutes for the ASG and ELB to boot up, so retry a few times
	//	maxRetries := 30
	timeBetweenRetries := 5 * time.Second

	// Verify that the ELB returns a proper response
	elbChecks := retry.DoInBackgroundUntilStopped(t, fmt.Sprintf("Check URL %s", url), timeBetweenRetries, func() {
		http_helper.HttpGetWithCustomValidation(t, url, func(statusCode int, body string) bool {
			return statusCode == 200
		})
	})

	// Stop checking the ELB
	elbChecks.Done()
}
