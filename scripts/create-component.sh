#!/bin/bash

# Check if the component name is provided
if [ -z "$1" ]; then
  echo "Error: Please provide a component name."
  echo "Usage: create-component <ComponentName>"
  exit 1
fi

# Assign the first parameter to componentName (case-sensitive)
componentName="$1"

# Create the folder (case-sensitive name)
mkdir -p "$componentName"

# Create the .jsx file with a basic template
cat <<EOF > "$componentName/$componentName.jsx"
/*<---------------------------------------------------------------------------->
<!--	$componentName (Component)	-->
<!----------------------------------------------------------------------------->
* Description:
     
* Parameters:
    -
* Dependencies:
    -
* Returns/results:
    
<!------------------------------------------------->*/

//---------------------imports----------------------

//styles
import styles from './$componentName.module.css'


export default function $componentName() {
  return (
    <>
      
    </>
  );
}

/*<!--------------------------------------------------------------------------->
<!--	end $componentName(Component)	-->
<!--------------------------------------------------------------------------->*/

EOF

# Create the .module.css file with a basic template
cat <<EOF > "$componentName/$componentName.module.css"
/*###################################################*/
/*...................................................*/
/* $componentName(component) */
/*...................................................*/
/*###################################################*/



/*###################################################*/
/*...................................................*/
/* end $componentName(component) */
/*...................................................*/
/*###################################################*/
EOF

# Open the created files in VS Code (reuse the current window)
if command -v code &> /dev/null; then
  code --reuse-window "$componentName/$componentName.jsx" "$componentName/$componentName.module.css"
  echo "Files '$componentName.jsx' and '$componentName.module.css' opened in the existing VS Code window."
else
  echo "VS Code is not installed or 'code' command is not in PATH. Please open the files manually."
fi

# Success message
echo "Component '$componentName' created successfully!"

# instrucciones: 
# muévelo para que sea global: sudo mv create-component.sh /usr/local/bin/create-component
# hazlo ejecutable con chmod +x /usr/local/bin/create-component
