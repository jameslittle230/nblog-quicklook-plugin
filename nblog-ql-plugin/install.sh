#!/bin/sh

#  install.sh
#  nblog-ql-plugin-2
#
#  Created by James Little on 10/16/17.
#  Copyright © 2017 James Little. All rights reserved.

PRODUCT="${PRODUCT_NAME}.qlgenerator"
QL_PATH=~/Library/QuickLook/

rm -rf "$QL_PATH/$PRODUCT"
test -d "$QL_PATH" || mkdir -p "$QL_PATH" && cp -R "$BUILT_PRODUCTS_DIR/$PRODUCT" "$QL_PATH"
qlmanage -r

echo "$PRODUCT installed in $QL_PATH"
