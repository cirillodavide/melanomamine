# The script defines standard pipeline for performing:
# 1. Feature dictionary building
# 2. Removing stopwords in dictionary
# 3. Convert the positive and negative document collections 
# 	into feature vector 
# 4. Prepare training and testing data for SVM.
# 5. Run SVM learner and classifier
# 6. Analyze the model learnt by SVM

# Step 1: Feature Dictionary Building from POSITIVE N NEGATIVE collection.
# Prepare the list of features from positive and negative training examples. 
# The script also removes words which are numbers or single letters. 
# Arguments: 
# 1. POSITIVE COLLECTION
# 2. NEGATIVE COLLECTION
# 3. feature dictionary file
echo "Preparing feature dictionary from positive and negative training examples.";
perl prepare_feature_file.pl input/training_tp.txt input/training_tn.txt output/feature_dictionary.txt

# Step 2: Remove the stopwords from the list of features
# Arguments:
# 1. Stopword list
# 2. Additional stopwords (problem specific)
# 2. feature dictionary file
echo "Filtering feature dictionary to remove stopwords.";
perl remove_stop_words.pl input/stopword1.txt input/additional_stopwords.txt output/feature_dictionary.txt output/feature_dictionary_filtered.txt

# Step 3a: Generate the fetaures for TRUE POSITIVE collection of protein protein interaction data
# The input file format is PMID\tTITLE\tABSTRACT
# The features are written in tp_features.txt file.
echo "Convert the positive training examples to feature vector.";
./convert2vector output/feature_dictionary_filtered.txt input/training_tp.txt output/tp_features.txt 3 +1  output/sorted_feature_dictionary_filtered.txt > log_tp

# Step 3b: Generate the fetaures for TRUE NEGATIVE collection of protein protein interaction data
# The input file format is PMID\tABSTRACT
# The features are written in tn_features.txt file.
echo "Convert the negative training examples to feature vector.";
./convert2vector output/feature_dictionary_filtered.txt input/training_tn.txt output/tn_features.txt 3 -1 output/sorted_feature_dictionary_filtered.txt > log_tn

# Step 4: Prepare training and testing data for SVM.  We extract here first 400 examples 
# from each of tp_features.txt and tn_features.txt and form svm.test for testing the classifier
# with 800 test examples.  The remaining examples from both the files form training examples
# for SVM in svm.train.
echo "Prepare training and test data for SVM experiments.";
perl svm_data_preparation.pl 400 output/tp_features.txt output/tn_features.txt output/svm.train output/svm.test

# Step 5: Execute SVM related procedures
echo "Performing SVM learning.";
#/data/jmb4-ext/svm_light/svm_learn output/svm.train model/svm.model
svm_learn output/svm.train model/svm.model

echo "Classifying with model learnt by SVM .";
#/data/jmb4-ext/svm_light/svm_classify output/svm.test model/svm.model model/svm.predictions
svm_classify output/svm.test model/svm.model model/svm.predictions

# Step 6: Analyze the model
echo "Interpretation of the model learnt by SVM .";
perl analyze_model.pl output/sorted_feature_dictionary_filtered.txt model/svm.model > model/svm.score
