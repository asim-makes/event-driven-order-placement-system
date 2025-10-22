#!/bin/bash

set -e

REGION="us-east-1"

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/deployment_$(date +%Y%m%d_%H%M%S).log"

TEMPLATES_DIR="templates"

STACKS=(
    "base-infra.yaml:BaseInfraStack"
    "orders.yaml:OrdersStack"
    "inventory.yaml:InventoryStack"
    "payments.yaml:PaymentsStack"
    "shipping.yaml:ShippingStack"
)

mkdir -p "$LOG_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

echo "--- AWS CloudFormation Deployment Log ---" > "$LOG_FILE"
log_message "Starting sequential CloudFormation deployment in region: $REGION"
log_message "Templates directory: $TEMPLATES_DIR"
log_message "Log file path: $LOG_FILE"
log_message "------------------------------------------------------------"

for item in "${STACKS[@]}"; do
    IFS=':' read -r TEMPLATE_FILENAME STACK_NAME <<< "$item"
    
    TEMPLATE_FILE="$TEMPLATES_DIR/$TEMPLATE_FILENAME"

    log_message "Deploying stack: **$STACK_NAME** using template: **$TEMPLATE_FILE**"

    if [ ! -f "$TEMPLATE_FILE" ]; then
        log_message "Error: Template file **$TEMPLATE_FILE** not found! Aborting deployment."
        exit 1
    fi

    if ! aws cloudformation deploy \
        --template-file "$TEMPLATE_FILE" \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        --capabilities CAPABILITY_NAMED_IAM \
        --no-fail-on-empty-changeset \
        2>&1 | tee -a "$LOG_FILE"; then
        
        log_message "Deployment failed for stack **$STACK_NAME**! Check the log file for details."
        exit 1
    fi

    log_message "Stack **$STACK_NAME** deployed successfully."
    log_message ""
done

log_message "------------------------------------------------------------"
log_message "All 5 CloudFormation stacks have been deployed successfully!"