1. Compile the c++ script convert2vector.cc

c++ -std=c++1y convert2vector.cc -o convert2vector

2. Train the classifier and generate the model:

./pipeline.sh

3. Convert unlabeled documents to feature vector (e.g. PubMed):

convert2vector output/feature_dictionary_filtered.txt in_path out_path  3 +1  output/sorted_feature_dictionary_filtered.txt

4. Classify feature vectors:

svm_classify in_path model/svm.model out_path

5. Map scores to document ides (PMIDs):

python map_predictions2pmid.py in_path.vector in_path.class
