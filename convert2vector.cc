#include<iostream>
#include<fstream>
#include<map>
#include<deque>
#include<cctype>
using namespace std;

// The program converts the documents to feature vector 
// using a list of precompiled features.  
// Input: Abstracts from MEDLINE in the following format:
// 	PMID\tTitle\tAbstract
// List of features

void readFeatures(const string& featureFile, map<string, int>& mapFeatureIndex, 
		const string& sortedFeatureFile)
{
	ifstream featureReader( featureFile.c_str() );
	if( !featureReader ){
		cerr << "The program could not open the file:"<< featureFile <<"\n";
	  exit(1);
	}  

	ofstream featureWriter( sortedFeatureFile.c_str() );
	if( !featureWriter ){
		cerr << "The program could not open the file:"<< sortedFeatureFile <<"\n";
	  exit(1);
	}

	string feature;
	deque<string> featureList;	
	while( getline(featureReader, feature) ){
		featureList.push_back( feature );
	}
	featureReader.close();

	sort( featureList.begin(), featureList.end() );

	cout << "Building the feature map \n";
	int index = 1;
	deque<string>::iterator featureItr = featureList.begin();
	while(featureItr != featureList.end() ){
		//cout << index  << " " << *featureItr << "\n";	
		featureWriter << *featureItr << "\n";	
		mapFeatureIndex.insert( make_pair(*featureItr, index++) );
		featureItr++;	
	}

	featureWriter.close();
}

bool isStopLetter(string& letter)
{
	if( letter == "\'" || letter == "\"" || letter == "(" || letter == ")" ||   
			letter == "{" || letter == "}" || letter == "[" || letter == "]"	||
			letter == "-" || letter == "?" || letter == "!" || letter == "<"  ||
			letter == ";" || letter == ":" || letter == ">" || letter == "." || 
			letter == ","){
		return true;		
	}
	return false;
}


void convert2vector(string& abstract, map<string, int>& mapFeatureIndex, 
		ofstream& featureWriter, const string& label, const string& pmid)
{
	map<int,int> mapWordCount;
	int abstractWordCount = 0;
		  
	size_t index = 0;
	size_t prev_index = 0;
	while( index < abstract.length() ){
		index = abstract.find( " ", prev_index );
		index = ( index < abstract.size() )? index : abstract.size();		
		string word = abstract.substr(prev_index, index - prev_index);		
		//cout << "Extracted word #" << word << "# : ";
		std::transform( word.begin(), word.end(), word.begin(), (int(*)(int))std::tolower);

		if( word == "" ){
			prev_index = index + 1;
			//cout << "Empty word so continuing ... \n";	
			continue;
		}
		
		// remove punctuation marks at the either end of the word
		if( word.length() > 1 ){
			string start_letter = word.substr(0, 1);
			if( isStopLetter(start_letter) ) word = word.substr( 1, word.length() - 1 );
		
			string last_letter = word.substr(word.length() - 1, 1);
			if( isStopLetter(last_letter) ) word = word.substr( 0, word.length() - 1 );
		}

		//cout << "Processing word #" << word << "# : ";
		map<string,int>::iterator featureItr =  mapFeatureIndex.find(word);
		if( featureItr !=  mapFeatureIndex.end() ){
			//cout<< "Keyword \n";
			map<int,int>::iterator countItr =  mapWordCount.find( featureItr->second );
			if( countItr ==  mapWordCount.end() ) mapWordCount.insert( make_pair( featureItr->second, 1) );	
				else (countItr->second)++;
		}/*else{
			cout<< "normal\n";
		}*/
		
		prev_index = index + 1;
		abstractWordCount++;
	}

	// do the conversion
	cout<<"Total words in abstract: " << abstractWordCount << "\n";
	//cout << label << " "; 
	featureWriter << label << " ";
	map<int,int>::iterator countItr =  mapWordCount.begin();
	while( countItr != mapWordCount.end() ){
		float val = (float)(countItr->second)/abstractWordCount;
		featureWriter << countItr->first << ":" << val << " ";
		//cout << countItr->first << ":" << val << " ";
		countItr++;	
	}
	featureWriter << "#" << pmid << "\n";
	//cout << "#" << pmid << "\n";
}

string getAbstract(string& record, const int& abstractFieldIndex, string& pmid)
{
	size_t tpos1 = record.find( "\t", 0 );
	pmid = record.substr( 0, tpos1 );

	if( abstractFieldIndex == 2 ){
		return record.substr( tpos1 + 1 );
	}
	
	size_t tpos2 = record.find( "\t", tpos1+1 );
	return record.substr( tpos2 + 1, record.length() );
}		  


int main(int argc, char** argv)
{
	// read the file containing feature words
	map<string, int> mapFeatureIndex;
	cout<<"Reading word features\n";
	readFeatures( argv[1], mapFeatureIndex, argv[6] );

	// read the abstract file and convert the abstracts into feature vectors
	ifstream abstractReader( argv[2] );
	if( !abstractReader ){
		cerr << "The program could not open the file:"<< argv[2] <<"\n";
		exit(1);
	}
	
	// open file for writing the features
	ofstream featureWriter( argv[3] ); 
	if( !featureWriter ){
		cerr << "The program could not open the file:"<< argv[3] <<"\n";
		exit(1);
	}
	
	string pubmedRecord;
	int abstractIndex = 0;
	while( getline(abstractReader, pubmedRecord) ){
		string pmid;
		string abstract = getAbstract( pubmedRecord, atoi(argv[4]), pmid ); 	
		//cout<<"Processing abstract: " << abstractIndex << ":#" << abstract  << "#\n";
		convert2vector( abstract, mapFeatureIndex, featureWriter, argv[5], pmid );
		abstractIndex++;
	}
		  
	return 0;
}

