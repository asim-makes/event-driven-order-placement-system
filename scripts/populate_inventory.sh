#!/bin/bash

INVENTORY_TABLE_NAME="InventoryTable" 
REGION="us-east-1"
INITIAL_STOCK=15

PRODUCTS=(
    "Mobile_Pro_Max_V10"
    "Laptop_XPS_Dev_Edition"
    "Suitcase_Large_Carryon"
    "Wireless_Headphones_ANC"
    "Smart_Watch_Series_7"
    "Gaming_Console_Gen_Z"
    "4K_Monitor_Curved_32in"
    "Robot_Vacuum_Cleaner"
    "Espresso_Machine_Auto"
    "Drone_Camera_Beginner"
    "Electric_Scooter_E500"
    "Water_Bottle_Insulated"
    "Mechanical_Keyboard_RGB"
    "Ergonomic_Office_Chair"
    "Security_Camera_Outdoor"
)

ITEM_COUNT=${#PRODUCTS[@]}

echo "Starting population of Inventory Table: ${INVENTORY_TABLE_NAME} in region ${REGION}."
echo "Adding ${ITEM_COUNT} items with initial stock of ${INITIAL_STOCK}..."

# Loop to create and put items
for i in "${!PRODUCTS[@]}"; do
    INDEX=$((i + 1))
    PRODUCT_NAME=${PRODUCTS[i]}
    ITEM_ID="ITEM_ID-$(printf "%02d" $INDEX)"
    
    ITEM_JSON='{
        "itemId": {"S": "'"${ITEM_ID}"'"},
        "productName": {"S": "'"${PRODUCT_NAME}"'"},
        "quantity": {"N": "'"${INITIAL_STOCK}"'"}
    }'

    # Execute the AWS CLI command
    aws dynamodb put-item \
        --table-name "${INVENTORY_TABLE_NAME}" \
        --item "${ITEM_JSON}" \
        --region "${REGION}" \
        --output text
    
    echo " -> Added item: ${ITEM_ID} (${PRODUCT_NAME})"
done

echo "✅ Inventory population complete. Total items added: ${ITEM_COUNT}"