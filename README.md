# LC-RT-Predictor
This MATLAB application has two tabs called:
  1) Multilinear Regression
  2) Artificial Neural Network
Each tab accepts two .csv files as input files:
  1) Genetic Algorithm (GA) Output File
  2) Input File
The GA output file is used as the model set and the second input file as the external set. For both of these input files, the app accepts a specific input format. Column 1 is the 'MOL_ID', which only accepts numerical ID and the last column is the Retention Time. All columns in between contain information about the molecular descriptors for each of the rows or MOL_ID's. An example of such a GA output file is included in the repository. Similarly, the second input file must have the same format, except there should not be the Retention Time column as that is what is being predicted. Also, note that the titles for all molecular descriptor columns must match between the two input files; otherwise, users will receive an error message. 

Once the input files are submitted, the app displays the results, which differ for the MLR tab and the ANN tab. For the MLR tab, once the calculation has completed, the following data will appear on the app:
  1) Model equation
  2) Predicted RT vs Experimental RT graph
  3) Data including: number of EDD's, Model to External ratio, R^2 value from model equation, etc...
  4) The Predicted RT's shown in table format
Meanwhile, on the ANN tab, the data that will appear after the calculations have completed are:
  1) Data including: number of EDD's, number of descriptors, and number of achieved R^2 (opposed to the target R^2)
  2) Predicted RT vs Experimental RT graph
  3) The Predicted RT's shown in table format
