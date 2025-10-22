#!/bin/bash

set -e

REGION="us-east-1"

LOG_DIR="logs"
LOG_FILE="$LOG_DIR/destruction_$(date +%Y%m%d_%H%M%S).log"

STACKS_TO_DESTROY=(
    "OrdersStack"
    "InventoryStack"
    "PaymentsStack"
    "ShippingStack"
    "BaseInfraStack"
)

mkdir -p "$LOG_DIR"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

echo "--- AWS CloudFormation Destruction Log ---" > "$LOG_FILE"
log_message "Starting sequential CloudFormation stack destruction in region: $REGION"
log_message "Log file path: $LOG_FILE"
log_message "------------------------------------------------------------"

for STACK_NAME in "${STACKS_TO_DESTROY[@]}"; do
    log_message "Attempting to delete stack: **$STACK_NAME**"

    if ! aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" &> /dev/null; then
        log_message "Stack **$STACK_NAME** does not exist or is already deleted. Skipping."
        log_message ""
        continue
    fi

    if ! aws cloudformation delete-stack \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        2>&1 | tee -a "$LOG_FILE"; then

        log_message "Initial delete command failed for stack **$STACK_NAME**."
        log_message "Check logs for immediate errors, but the script will attempt to wait for final status."
    fi

    log_message "⏳ Waiting for stack **$STACK_NAME** to complete deletion..."
    if aws cloudformation wait stack-delete-complete \
        --stack-name "$STACK_NAME" \
        --region "$REGION" \
        2>&1 | tee -a "$LOG_FILE"; then
        
        log_message "Stack **$STACK_NAME** deleted successfully."
    else
        log_message "Deletion failed or timed out for stack **$STACK_NAME**! Manual cleanup may be required."
        log_message "------------------------------------------------------------"
        exit 1
    fi
    log_message ""
done

log_message "------------------------------------------------------------"
log_message "All specified CloudFormation stacks have been destroyed successfully!"