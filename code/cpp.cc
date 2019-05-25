/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include <iterator>
using std::inserter;

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <algorithm>
using std::transform;

struct absInt {
    int operator()(int val) const {
        return val < 0 ? -val : val;
    }
};

int main() {
    int i = -42;
    absInt absObj;           // object that has a function-call operator
    unsigned ui = absObj(i); // passes i to absObj.operator()
    cout << i << " " << ui << endl;

	// store collection of positive and negative integers in vi
	vector<int> vi;
	while (cin >> i)
		vi.push_back(i);

	// call absInt to store the absolute value of those ints in vu
	vector<unsigned> vu;
	transform(vi.begin(), vi.end(), back_inserter(vu), absInt());

	// print contents of vu using a lambda
	for_each(vu.begin(), vu.end(), [](unsigned i) { cout << i << " "; });
	cout << endl;

	vector<unsigned> vu2;
	// similar transformation but using a lambda
	transform(vi.begin(), vi.end(), back_inserter(vu2),
	          [](int i) { return i < 0 ? -i : i; });
	if (vu == vu2)
		cout << "as expected" << endl;
	else {
		cout << "something's wrong, vectors differ" << endl;
		for_each(vu.begin(), vu.end(), [](unsigned i) { cout << i << " "; });
	}
	cout << endl;

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include <iterator>
using std::inserter;

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <algorithm>
using std::for_each; using std::transform;

int main() {
	vector<int> vi;
	int i;
	while (cin >> i)
		vi.push_back(i);
	// pass a lambda to for_each to print each element in vi
	for_each(vi.begin(), vi.end(), [](int i) { cout << i << " "; });
	cout << endl;

	vector<int> orig = vi; // save original data in vi

	// replace negative values by their absolute value
	transform(vi.begin(), vi.end(), vi.begin(),
	          [](int i) { return i < 0 ? -i : i; });
	// print the elements now in vi
	for_each(vi.begin(), vi.end(), [](int i) { cout << i << " "; });
	cout << endl;

	vi = orig;  // start afresh
	// use a lambda with a specified return type to transform vi
	transform(vi.begin(), vi.end(), vi.begin(),
	          [](int i) -> int
	          { if (i < 0) return -i; else return i; });
	// print the elements now in vi
	for_each(vi.begin(), vi.end(), [](int i) { cout << i << " "; });
	cout << endl;

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include "Account.h"

// define static data and function members
const string Account::accountType("Savings Account");
double Account::interestRate = initRate();

void Account::rate(double newRate)
{
    interestRate = newRate;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <algorithm>
using std::fill; using std::fill_n;

#include <numeric>
using std::accumulate;

#include <iterator>
using std::back_inserter;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	vector<int> vec(10);              // default initialized to 0
	fill(vec.begin(), vec.end(), 1);  // reset each element to 1

	// sum the elements in vec starting the summation with the value 0
	int sum = accumulate(vec.cbegin(), vec.cend(), 0);
	cout << sum << endl;

	// set a subsequence of the container to 10
	fill(vec.begin(), vec.begin() + vec.size()/2, 10);
	cout << accumulate(vec.begin(), vec.end(), 0) << endl;

	// reset the same subsequence to 0
	fill_n(vec.begin(), vec.size()/2, 0);
	cout << accumulate(vec.begin(), vec.end(), 0) << endl;

	// create 10 elements on the end of vec each with the value 42
	fill_n(back_inserter(vec), 10, 42);
	cout << accumulate(vec.begin(), vec.end(), 0) << endl;

	// concatenate elements in a vector of strings and store in sum
	vector<string> v;
	string s;
	while (cin >> s)
		v.push_back(s);
	string concat = accumulate(v.cbegin(), v.cend(), string(""));
	cout << concat << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <numeric>
using std::accumulate;

#include <iterator>
using std::istream_iterator;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	istream_iterator<int> in(cin), eof;
	cout << accumulate(in, eof, 0) << endl;
	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>

int main()
{
	// prompt user to enter two numbers
	std::cout << "Enter two numbers:" << std::endl;
	int v1 = 0, v2 = 0;
	std::cin >> v1 >> v2;
	std::cout << "The sum of " << v1 << " and " << v2
	          << " is " << v1 + v2 << std::endl;
	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include "Sales_data.h"
#include "Sales_item.h"

int main()
{
    Sales_item item1, item2;
    cin >> item1 >> item2;   //read a pair of transactions
    // print the sum of two Sales_items
    cout << item1 + item2 << endl;

	Sales_data data1, data2;
    read(read(cin, data1), data2);   //read a pair of transactions
    print(cout, add(data1, data2));  // print the sum of two Sales_datas
 	cout << std::endl;

	cin >> data1 >> data2; // use input operator to read Sales_datas
    // use operators to print the sum of two Sales_datas
    cout << data1 + data2 << endl;

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cerr; using std::cin; using std::cout; using std::endl;

#include "Sales_data.h"

int main()
{
	Sales_data data1, data2;
	if (read(cin, data1) && read(cin, data2)) {  // read the transactions
		if (data1.isbn() == data2.isbn()) {      // check isbns
			data1.combine(data2);                // add the transactions
			print(cout, data1);                  // print the results
			cout << endl;                        // followed by a newline
		}
	} else
		cerr << "Input failed!" << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Sales_data.h"
#include <iostream>

using std::cerr; using std::cin; using std::cout; using std::endl;

int main()
{
	Sales_data data1, data2;
	read(cin, data1);                       // read the transactions
	read(cin, data2);
	// code to add into data1 and data2 unchanged from chapter 7
	if (data1.isbn() == data2.isbn()) {     // check isbns
		Sales_data sum = add(data1, data2); // add the transactions
		print(cout, sum);                   // print the results
		cout << endl;                       // followed by a newline
	}

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
#include "Sales_item.h"

int main()
{
    Sales_item item1, item2;

    std::cin >> item1 >> item2;   //read a pair of transactions
    std::cout << item1 + item2 << std::endl; //print their sum

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <stdexcept>
using std::runtime_error;

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include "Sales_item.h"

int main()
{
	Sales_item item1, item2;

	while (cin >> item1 >> item2) {
	    try {
	        // execute code that will add the two Sales_items
	        // if the addition fails, the code throws a runtime_error exception
	        // first check that the data are for the same item
	        if (item1.isbn() != item2.isbn())
	            throw runtime_error("Data must refer to same ISBN");

	        // if we're still here, the ISBNs are the same
	        cout << item1 + item2 << endl;
	    } catch (runtime_error err) {
	        // remind the user that the ISBNs must match
			// and prompt for another pair
	        cout << err.what()
	             << "\nTry Again?  Enter y or n" << endl;
	        char c;
	        cin >> c;
	        if (!cin || c == 'n')
	            break;      // break out of the while loop
	    }  // ends the catch clause
	}  // ends the while loop

	return 0;   // indicate success
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
#include "Sales_item.h"

int main()
{
    Sales_item item1, item2;

    std::cin >> item1 >> item2;
	// first check that item1 and item2 represent the same book
	if (item1.isbn() == item2.isbn()) {
    	std::cout << item1 + item2 << std::endl;
    	return 0;   // indicate success
	} else {
    	std::cerr << "Data must refer to same ISBN"
		          << std::endl;
    	return -1;  // indicate failure
	}
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Sales_data.h"
#include <iostream>

using std::cerr; using std::cin; using std::cout; using std::endl;

int main()
{
	Sales_data data1, data2;
	if (read(cin, data1) && read(cin, data2)) {  // read the transactions
		if (data1.isbn() == data2.isbn()) {      // check isbns
			Sales_data sum = add(data1, data2);  // add the transactions
			print(cout, sum);                    // print the results
			cout << endl;                        // followed by a newline
		}
	} else
		cerr << "Input failed!" << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>

// using declarations for names from the standard library
using std::cin;
using std::cout; using std::endl;

int main()
{
	cout << "Enter two numbers:" << endl;

	int v1, v2;
	cin >> v1 >> v2;

	cout << "The sum of " << v1 << " and " << v2
	     << " is " << v1 + v2 << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <iostream>
using std::istream; using std::ostream;
using std::cin; using std::cout; using std::endl;

#include "Foo.h"

// factory returns a pointer to a dynamically allocated object
Foo* factory(T arg)
{
	// process arg as appropriate
	return new Foo(arg); // caller is responsible for deleting this memory
}

Foo* use_factory(T arg)
{
	Foo *p = factory(arg);
	print(cout, *p);
	cout << endl;
	// use p
	return p;  // caller must delete the memory
}

int main()
{
	T arg;
	while (cin >> arg) {
		auto p = use_factory(arg);
		delete p; // remember to delete the memory from use_factory
	}

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <memory>
using std::make_shared; using std::shared_ptr;

#include <iostream>
using std::istream; using std::ostream;
using std::cin; using std::cout; using std::endl;

#include "Foo.h"

// factory returns a shared_ptr to a dynamically allocated object
shared_ptr<Foo> factory(T arg)
{
	// process arg as appropriate
	// shared_ptr will take care of deleting this memory
	return make_shared<Foo>(arg);
}

shared_ptr<Foo> use_factory(T arg)
{
	shared_ptr<Foo> p = factory(arg);
	print(cout, *p);
	cout << endl;
	// use p
	return p;  // reference count is incremented when we return p
}

int main()
{
	T arg;
	while (cin >> arg)
		use_factory(arg);
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Query.h"
#include "TextQuery.h"

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include <set>
using std::set;

int main(int argc, char **argv)
{
	// gets file to read and builds map to support queries
	TextQuery file = get_file(argc, argv);

    do {
        string sought1, sought2;
        // stop if hit eof on input or a "q" is entered
        if (!get_words(sought1, sought2)) break;

        // find all the occurrences of the requested string
        Query andq = Query(sought1) & Query(sought2);
        cout << "\nExecuting query for: " << andq << endl;
        auto results = andq.eval(file);
        // report matches
        print(cout, results);

        results = Query(sought1).eval(file);
        cout << "\nExecuted query: " << Query(sought1) << endl;
        // report matches
        print(cout, results);

        results = Query(sought2).eval(file);
        cout << "\nExecuted query: " << Query(sought2) << endl;
        // report matches
        print(cout, results);
    } while(true);

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Query.h"
#include "TextQuery.h"
#include <string>
#include <set>
#include <iostream>

using std::set;
using std::string;
using std::cin; using std::cout; using std::cerr;
using std::endl;

int main(int argc, char **argv)
{
    // gets file to read and builds map to support queries
    TextQuery file = get_file(argc, argv);

    // iterate with the user: prompt for a word to find and print results
    while (true) {
        string sought1, sought2, sought3;
        if (!get_words(sought1, sought2)) break;
        cout << "\nenter third word: " ;
        cin  >> sought3;
        // find all the occurrences of the requested string
        Query q = Query(sought1) & Query(sought2)
                             | Query(sought3);
        cout << "\nExecuting Query for: " << q << endl;
        const auto results = q.eval(file);
        // report matches
		print(cout, results);
     }
     return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Animal.h"
#include <iostream>
using std::ostream; using std::cout; using std::endl;

// operations that take references to base classes of type Panda
void print(const Bear&)
{
	cout << "print(const Bear&)" << std::endl;

}
void highlight(const Endangered&)
{
	cout << "highlight(const Endangered&)" << std::endl;
}

ostream& operator<<(ostream &os, const ZooAnimal&)
{
	return os << "ZooAnimal output operator" << endl;
}

int main() {
	Panda ying_yang("ying_yang");

	print(ying_yang);     // passes Panda to a reference to Bear
	highlight(ying_yang); // passes Panda to a reference to Endangered
	cout << ying_yang << endl; // passes Panda to a reference to ZooAnimal
	Panda ling_ling = ying_yang;    // uses the copy constructor

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

int main()
{
	cout << -30 * 3 + 21 / 5 << endl;

	cout << -30 + 3 * 21 / 5 << endl;

	cout << 30 / 3 * 21 % 5 << endl;

	cout << 30 / 3 * 21 % 4 << endl;

	cout << -30 / 3 * 21 % 4 << endl;

	cout << 12 / 3 * 4 + 5 * 15 + 24 % 4 / 2 << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include <cstddef>
using std::size_t;

// when we call print the compiler will instantiate a version of print
// with T replaced by the argument's element type, and N by that array's dimension
template <typename T, size_t N>
void print(T (&arr)[N])
{
    for (auto elem : arr)
        cout << elem << endl;
}

int main()
{
	int a1[] = {0,1,2,3,4,5,6,7,8,9};
	int a2[] = {1,3,5};
	string a3[4];

	print(a1);  // instantiates print(int (&arr)[10])

	print(a2);  // instantiates print(int (&arr)[3])

	print(a3);  // instantiates print(string (&arr)[42])

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iterator>
using std::begin; using std::end;

#include <list>
using std::list;

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

#include <initializer_list>
using std::initializer_list;

#include <cstddef>
using std::size_t;

#include "Blob.h"

int main()
{
    Blob<int> ia;                // empty Blob<int>
	Blob<int> ia2 = {0,1,2,3,4}; // Blob<int> with five elements
	vector<int> v1(10, 0); // ten elements initialized to 0
    Blob<int> ia3(v1.begin(), v1.end());  // copy elements from v1
    cout << ia << "\n" << ia2 << "\n" << ia3 << endl;

    // these definitions instantiate two distinct Blob types
    Blob<string> names; // Blob that holds strings
    Blob<double> prices;// different element type

	// instantiates Blob<string> class and its
	//  initializer_list<const char*> constructor
	Blob<string> articles = {"a", "an", "the"}; // three elements

	// instantiates Blob<int> and the initializer_list<int> constructor
	Blob<int> squares = {0,1,2,3,4,5,6,7,8,9};

	// instantiates Blob<int>::size() const
    cout << squares << endl;
	for (size_t i = 0; i != squares.size(); ++i)
		squares[i] = i*i; // instantiates Blob<int>::operator[](size_t)
    cout << squares << endl;

	// instantiates the Blob<int> constructor that has
	// two vector<long>::iterator parameters
	vector<long> vl = {0,1,2,3,4,5,6,7,8,9};
	Blob<int> a1(vl.begin(), vl.end());   // copy from a vector

	// instantiates the Blob<int> class
	// and the Blob<int> constructor that has two int* parameters
	int arr[] = {0,1,2,3,4,5,6,7,8,9};
	Blob<int> a2(begin(arr), end(arr));   // copy from an array

	list<int> li(10, 0); // 10 elements all zeros
	Blob<int> zeros(li.begin(), li.end());  // copy from a list

    cout << a1 << "\n" << zeros << endl;

	a1.swap(zeros);
    cout << a1 << "\n" << zeros << endl;

	list<const char*> w = {"now", "is", "the", "time"};

	// instantiates the Blob<string> class and the Blob<string>
	// constructor that has two (list<const char*>::iterator parameters
	Blob<string> a3(w.begin(), w.end());  // copy from a list

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <vector>
using std::vector;

#include <iostream>
using std::cin; using std::cout; using std::endl;


int main ()
{
	vector<unsigned> grades;
	// count the number of grades by clusters of ten:
	// 0--9, 10--19, . . . 90--99, 100
	unsigned scores[11] = {};  // 11 buckets, all value initialized to 0
	unsigned grade;
	while (cin >> grade) {
		if (grade <= 100)
			// increment the counter for the current cluster
			++scores[grade/10];
		grades.push_back(grade);
	}
	cout << "grades.size = " << grades.size() << endl;

	for (auto g : grades)  // for every element in grades
		cout << g << " " ;
	cout << endl;

	for (auto i : scores)       // for each counter in scores
		cout << i << " ";       // print the value of that counter
	cout << endl;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <cstddef>
using std::size_t;

int ia[] = {0,1,2,3,4,5,6,7,8,9};

int main()
{
   // sizeof(ia)/sizeof(*ia) returns the number of elements in ia
   constexpr size_t sz = sizeof(ia)/sizeof(*ia);

   int arr2[sz];  // ok sizeof returns a constant expression

   cout << "ia size: " << sz << endl;

   return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <iostream>
using std::cout; using std::endl;

// code to illustrate declarations of array-related types
int arr[10];          // arr is an array of ten ints
int *p1[10];          // p1 is an array of ten pointers
int (*p2)[10] = &arr; // p2 points to an array of ten ints

using arrT = int[10]; // arrT is a synonym for the type array of ten ints

// three ways to declare function returning pointer to array of ten ints
arrT* func(int i);               // use a type alias
auto func(int i) -> int(*)[10];  // use a trailing return type
int (*func(int i))[10];          // direct declaration

auto func2(int i) -> int(&)[10]; // func2 returns a refernce to an array

// two arrays
int odd[] = {1,3,5,7,9};
int even[] = {0,2,4,6,8};

// function that returns a pointer to an int in one of these arrays
int *elemPtr(int i)
{
	// returns a pointer to the first element in one of these arrays
	return (i % 2) ? odd : even;
}

// returns a pointer to an array of five int elements
decltype(odd) *arrPtr(int i)
{
	return (i % 2) ? &odd : &even; // returns a pointer to the array
}

// returns a reference to an array of five int elements
int (&arrRef(int i))[5]
{
	return (i % 2) ? odd : even;
}

int main()
{
	int *p = elemPtr(6);         // p points to an int
	int (*arrP)[5] = arrPtr(5);  // arrP points to an array of five ints
	int (&arrR)[5] = arrRef(4);  // arrR refers to an array of five ints

	for (size_t i = 0; i < 5; ++i)
		// p points to an element in an array, which we subscript
		cout << p[i] << endl;

	for (size_t i = 0; i < 5; ++i)
		// arrP points to an array,
		// we must dereference the pointer to get the array itself
		cout << (*arrP)[i] << endl;

	for (size_t i = 0; i < 5; ++i)
		// arrR refers to an array, which we can subscript
		cout << arrR[i] << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cerr; using std::cin; using std::cout; using std::endl;

#include "Sales_data.h"

int main()
{
	Sales_data total;         // variable to hold the running sum
	if (read(cin, total))  {  // read the first transaction
		Sales_data trans;     // variable to hold data for the next transaction
		while(read(cin, trans)) {      // read the remaining transactions
			if (total.isbn() == trans.isbn())   // check the isbns
				total.combine(trans);  // update the running total
			else {
				print(cout, total) << endl;  // print the results
				total = trans;               // process the next book
			}
		}
		print(cout, total) << endl;          // print the last transaction
	} else {                                 // there was no input
		cerr << "No data?!" << endl;         // notify the user
	}

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iterator>
using std::istream_iterator; using std::ostream_iterator;

#include <iostream>
using std::cin; using std::cout;

#include "Sales_item.h"

int main()
{
	// iterators that can read and write Sales_items
	istream_iterator<Sales_item> item_iter(cin), eof;
	ostream_iterator<Sales_item> out_iter(cout, "\n");

	// store the first transaction in sum and read the next record
	Sales_item sum = *item_iter++;

	while (item_iter != eof) {
		// if the current transaction (which is in item_iter)
		// has the same ISBN
	    if (item_iter->isbn() == sum.isbn())
	        sum += *item_iter++; // add it to sum
		                         // and read the next transaction
	    else {
	        out_iter = sum;      // write the current sum
	        sum = *item_iter++;  // read the next transaction
	    }
	}
	out_iter = sum;  // remember to print the last set of records

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
#include "Sales_item.h"

int main()
{
    Sales_item total; // variable to hold data for the next transaction

    // read the first transaction and ensure that there are data to process
    if (std::cin >> total) {
		Sales_item trans; // variable to hold the running sum
        // read and process the remaining transactions
        while (std::cin >> trans) {
			// if we're still processing the same book
            if (total.isbn() == trans.isbn())
                total += trans; // update the running total
            else {
		        // print results for the previous book
                std::cout << total << std::endl;
                total = trans;  // total now refers to the next book
            }
		}
        std::cout << total << std::endl; // print the last transaction
    } else {
        // no input! warn the user
        std::cerr << "No data?!" << std::endl;
        return -1;  // indicate failure
    }

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstdio> // for EOF
#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	char ch;    // using a char here invites disaster!

	// the return from cin.get is converted to char
	// and then compared to an int
	while ((ch = cin.get()) != EOF)
         	cout.put(ch);
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Quote.h"
#include "Basket.h"

#include <cstddef>
using std::size_t;

#include <set>
using std::multiset;

#include <string>
using std::string;

#include <iostream>
using std::ostream; using std::endl;
using std::cout;

// debugging routine to check contents in a Basket
void Basket::display(ostream &os) const
{
    os << "Basket size: " << items.size() << endl;

    // print each distinct ISBN in the Basket along with
    // count of how many copies are ordered and what their price will be
    // upper_bound returns an iterator to the next item in the set
    for (auto next_item = items.cbegin();
              next_item != items.cend();
              next_item = items.upper_bound(*next_item))
    {
        // we know there's at least one element with this key in the Basket
        os << (*next_item)->isbn() << " occurs "
           << items.count(*next_item) << " times"
           << " for a price of "
           << (*next_item)->net_price(items.count(*next_item))
           << endl;
    }
}

double Basket::total_receipt(ostream &os) const
{
    double sum = 0.0;    // holds the running total


    // iter refers to the first element in a batch of elements with the same ISBN
    // upper_bound returns an iterator to the element just past the end of that batch
    for (auto iter = items.cbegin();
              iter != items.cend();
              iter = items.upper_bound(*iter)) {
        // we know there's at least one element with this key in the Basket
		// print the line item for this book
        sum += print_total(os, **iter, items.count(*iter));
    }
	os << "Total Sale: " << sum << endl; // print the final overall total
    return sum;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <memory>
using std::shared_ptr; using std::make_shared;
#include "Basket.h"
#include <iostream>
using std::cout; using std::endl;

int main()
{
	Basket sale;
	sale.add_item(shared_ptr<Quote>(new Quote("123", 45)));
	sale.add_item(shared_ptr<Quote>(new Quote("123", 45)));
	sale.add_item(shared_ptr<Quote>(new Quote("123", 45)));
	sale.add_item(make_shared<Bulk_quote>("345", 45, 3, .15));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("345", 45, 3, .15)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("345", 45, 3, .15)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("345", 45, 3, .15)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("345", 45, 3, .15)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("345", 45, 3, .15)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("345", 45, 3, .15)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("345", 45, 3, .15)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("678", 55, 5, .25)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("678", 55, 5, .25)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("678", 55, 5, .25)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("678", 55, 5, .25)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("678", 55, 5, .25)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("678", 55, 5, .25)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("678", 55, 5, .25)));
	sale.add_item(shared_ptr<Quote>(new Bulk_quote("678", 55, 5, .25)));
	sale.add_item(shared_ptr<Quote>(new Lim_quote("abc", 35, 2, .10)));
	sale.add_item(shared_ptr<Quote>(new Lim_quote("abc", 35, 2, .10)));
	sale.add_item(shared_ptr<Quote>(new Lim_quote("abc", 35, 2, .10)));
	sale.add_item(shared_ptr<Quote>(new Lim_quote("abc", 35, 2, .10)));
	sale.add_item(shared_ptr<Quote>(new Lim_quote("abc", 35, 2, .10)));
	sale.add_item(shared_ptr<Quote>(new Lim_quote("abc", 35, 2, .10)));
	sale.add_item(shared_ptr<Quote>(new Quote("def", 35)));
	sale.add_item(shared_ptr<Quote>(new Quote("def", 35)));

	sale.total_receipt(cout);

	Basket bsk;
	// arguments are the ISBN, price, minimum quantity, and discount
	bsk.add_item(shared_ptr<Quote>(new Bulk_quote("0-201-82470-1", 50, 5, .19)));
	bsk.add_item(shared_ptr<Quote>(new Bulk_quote("0-201-82470-1", 50, 5, .19)));
	bsk.add_item(shared_ptr<Quote>(new Bulk_quote("0-201-82470-1", 50, 5, .19)));
	bsk.add_item(shared_ptr<Quote>(new Bulk_quote("0-201-82470-1", 50, 5, .19)));
	bsk.add_item(shared_ptr<Quote>(new Bulk_quote("0-201-82470-1", 50, 5, .19)));
	bsk.add_item(shared_ptr<Quote>(new Lim_quote("0-201-54848-8", 35, 2, .10)));
	bsk.add_item(shared_ptr<Quote>(new Lim_quote("0-201-54848-8", 35, 2, .10)));
	bsk.add_item(shared_ptr<Quote>(new Lim_quote("0-201-54848-8", 35, 2, .10)));
	bsk.total_receipt(cout);
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::for_each;

#include <functional>
using std::bind; using namespace std::placeholders;
using std::ref;

#include <iterator>
using std::istream_iterator;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::cin; using std::endl;
using std::ostream;

#include <fstream>
using std::ifstream; using std::ofstream;

ostream &print(ostream &os, const string &s, char c)
{
	return os << s << c;
}

int main()
{
	string s;
	vector<string> words;
	while (cin >> s)
		words.push_back(s);

	for_each(words.begin(), words.end(),
	         bind(print, ref(cout), _1, ' '));
	cout << endl;

	ofstream os("data/outFile1");
	for_each(words.begin(), words.end(),
	         bind(print, ref(os), _1, ' '));
	os << endl;

	ifstream is("data/outFile1");
	istream_iterator<string> in(is), eof;
	for_each(in, eof, bind(print, ref(cout), _1, '\n'));
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced. Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/
#include <iostream>
using std::cout; using std::endl;

typedef unsigned int Bit;

class File {
    Bit mode: 2;       // mode has 2 bits
    Bit modified: 1;   // modified has 1 bit
    Bit prot_owner: 3; // prot_owner has 3 bits
    Bit prot_group: 3; // prot_group has 3 bits
    Bit prot_world: 3; // prot_world has 3 bits
    // operations and data members of File
public:
	// file modes specified as octal literals; see XREF(intLiterals)
	enum modes { READ = 01, WRITE = 02, EXECUTE = 03 };
	File &open(modes);
	void close();
	void write();
	bool isRead() const;
	void setWrite();
	void execute();
	bool isExecute() const;
};

void File::write()
{
    modified = 1;
    // . . .
}

void File::close()
{
    if (modified)
        // . . . save contents
	;
}

inline bool File::isRead() const { return mode & READ; }
inline void File::setWrite() { mode |= WRITE; }


File &File::open(File::modes m)
{
	mode |= READ;    // set the READ bit by default
	// other processing
	if (m & WRITE) // if opening READ and WRITE
	// processing to open the file in read/write mode
	cout << "myFile.mode READ is set" << endl;
	return *this;
}

int main()
{
	File myFile;

	myFile.open(File::READ);
	if (myFile.isRead())
		cout << "reading" << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
#include <iostream>
#include <string>
using std::cout; using std::cin;
using std::endl;
using std::string;
using std::size_t;

#include <bitset>
using std::bitset;
int main()
{
	bitset<32> bitvec(1U); // 32 bits; low-order bit is 1,
	                       // remaining bits are 0
	bool is_set = bitvec.any();      // true, one bit is set
	bool is_not_set = bitvec.none(); // false, one bit is set
	bool all_set = bitvec.all();     // false, only one bit is set
	size_t onBits = bitvec.count();  // returns 1
	size_t sz = bitvec.size();       // returns 32

	bitvec.flip();     // reverses the value of all the bits in bitvec
	bitvec.reset();    // sets all the bits to 0
	bitvec.set();      // sets all the bits to 1

	cout << "bitvec: " << bitvec << endl;

	sz = bitvec.size();  // returns 32

	onBits = bitvec.count();  // returns 1,
                              // i.e., the number of bits that are on

	// assign 1 to even numbered bits
	for (int index = 0; index != 32; index += 2)
		bitvec[index] = 1;

	// equivalent loop using set operation
	for (int index = 0; index != 32; index += 2)
		bitvec.set(index);

	// bitvec is unchanged
	auto b2 = ~bitvec;  // b2 is a copy of bitvec with every bit flipped

	// assign value of last bit in bitvec to the first bit in b2
	b2[0] = bitvec[bitvec.size() - 1];
	bitvec[0] = 0;          // turn off the bit at position 0
	bitvec[31] = bitvec[0]; // give last bit the same value as the first
	bitvec[0].flip();       // flip the value of the bit at position 0
	~bitvec[0];             // equivalent; flips the bit at position 0
	bool b = bitvec[0];     // convert the value of bitvec[0] to bool
	b2[0] = ~bitvec[0];     // first bit in b2 has the opposite value
                            // of the first bit in bitvec

	unsigned i = 0;
	if (bitvec.test(i))
	     // bitvec[i] is on
	        ;

	//equivalent test using subscript
	if (bitvec[i])
	     // bitvec[i] is on
	        ;

	cout << "bitvec: positions turned on:\n\t";
	for (int index = 0; index != 32; ++index)
		if (bitvec[index])
	    	cout << index << " ";
	cout << endl;

	// equivalent; turn off first bit
	bitvec.flip(0);   // reverses the value of the first bit
	bitvec.set(bitvec.size() - 1);  // turns on the last bit
	bitvec.set(0, 0); // turns off the first bit
	bitvec.reset(i);  // turns off the ith bit
	bitvec.test(0);   // returns false because the first bit is off
	bitvec[0] = 0;

	bitvec.flip(0);   // reverses value of first bit
	bitvec[0].flip(); // also reverses the first bit

	cout << "new inits" <<endl;
	// bits13 is smaller than the initializer;
	// high-order bits from the initializer are discarded
	bitset<13> bits13(0xbeef);  // bits are 1111011101111

	// bits20 is larger than the initializer;
	// high-order bits in bits20 are set to zero
	bitset<20> bits20(0xbeef);  // bits are 00001011111011101111

	// on machines with 64-bit long long 0ULL is 64 bits of 0,
	// so ~0ULL is 64 ones, so 0 ... 63 are one, and 64 ... 127 are zero
    // if long long has 32 bits, 0 ... 32 are one, 33 ... 127 are zero
	bitset<128> bits128(~0ULL);
	cout << "bits13: " << bits13 << endl;
	cout << "bits20: " << bits20 << endl;
	cout << "bits128: " << bits128 << endl;
	cout << "bits20[0] " << bits20[0] << endl;
	cout << "bits20[19] " << bits20[19] << endl;

	// bitvec1 is smaller than the initializer
	bitset<32> bitvec1(0xffff);  // bits 0 ... 15 are set to 1;
	                             // 16 ... 31 are 0

	// bitvec2 same size as initializer
	bitset<64> bitvec2(0xffff);  // bits 0 ... 15 are set to 1;
	                             // 16 ... 63 are 0

	// assuming 64-bit long long, bits 0 to 63 initialized from 0xffff
	bitset<128> bitvec3(0xffff); // bits 32 through 127 are zero

	cout << "bitvec1: " << bitvec1 << endl;
	cout << "bitvec2: " << bitvec2 << endl;
	cout << "bitvec2[0] " << bitvec2[0] << endl;
	cout << "bitvec2[31] " << bitvec2[31] << endl;

	cout << "bitvec3: " << bitvec3 << endl;


	bitset<32> bitvec4("1100"); // bits 2 and 3 are 1, all others are 0

	cout << "strval: " << "1100" << endl;
	cout << "bitvec4: " << bitvec4 << endl;

	string str("1111111000000011001101");
	bitset<32> bitvec5(str, 5, 4); // four bits starting at str[5], 1100
	bitset<32> bitvec6(str, str.size()-4); // use last four characters

	cout << "str: " << str << endl;
	cout << "bitvec5: " << bitvec5 << endl;

	cout << "str: " << str << endl;
	cout << "bitvec6: " << bitvec6 << endl;

	unsigned long ulong = bitvec3.to_ulong();
	cout << "ulong = " << ulong << endl;

	bitset<32> bitvec7 = bitvec1 & bitvec4;

	cout << "bitvec7: " << bitvec7 << endl;

	bitset<32> bitvec8 = bitvec1 | bitvec4;

	cout << "bitvec8: " << bitvec8 << endl;

	bitset<16> chk("111100110011001100000");
	cout << "chk: " << chk << endl;

	bitset<16> bits;
	cin >> bits;  // read up to 16 1 or 0 characters from cin
	cout << "bits: " << bits << endl; // print what we just read

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Sales_data.h"
#include "bookexcept.h"

#include <iostream>
using std::cin; using std::cerr; using std::endl;

int main()
{
    // use the hypothetical bookstore exceptions
    Sales_data item1, item2, sum;
    while (cin >> item1 >> item2) {  // read two transactions
        try {
            sum = item1 + item2;     // calculate their sum
            // use sum
        } catch (const isbn_mismatch &e) {
          cerr << e.what() << ": left isbn(" << e.left
               << ") right isbn(" << e.right << ")" << endl;
        }
    }
     return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::endl; using std::flush; using std::ends;
using std::unitbuf; using std::nounitbuf; using std::cout;

int main()
{
	// writes hi and a newline, then flushes the buffer
    cout << "hi!" << endl;

	// writes hi, then flushes the buffer; adds no data
    cout << "hi!" << flush;

	// writes hi and a null, then flushes the buffer
    cout << "hi!" << ends;

    cout << unitbuf;         // all writes will be flushed immediately

	// any output is flushed immediately, no buffering
    cout << "first" << " second" << endl;

	cout << nounitbuf;       // returns to normal buffering

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Blob.h"
#include "compare.h"

#include <string>
using std::string;

// templateBuild.cc
// instantiation file must provide a (nonextern) definition for every
// type and function that other files declare as extern
template int compare(const int&, const int&);
template class Blob<string>; // instantiates all members of the class template
template class Blob<int>;    // instantiates Blob<int>
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;
using std::ostream;

#include <map>
using std::map;

#include <string>
using std::string;

#include <functional>
using std::bind; using std::function;
using namespace std::placeholders;

// this version of the desk calculator adds a class that
// represents both the left and right shift operators.
// This calss illustrates using pointers to member
// in the desk calculator
struct ShiftOps {
	ShiftOps(std::ostream &o) : os(o) { }
	unsigned Lshift(unsigned op1, unsigned op2)
	{ os << "Lshift: " << op1 << " " << op2; return op1 << op2; }
	unsigned Rshift(unsigned op1, unsigned op2)
	{ os << "Rshift: " << op1 << " " << op2; return op1 >> op2; }
private:
	std::ostream &os;
};

// ordinary function
int add(int i, int j) { return i + j; }

// lambda, which generates an unnamed function-object class
auto mod = [](int i, int j) { return i % j; };

// function-object class
// Note, in the first printing of The Primer this struct was named div
struct divide {
    int operator()(int denominator, int divisor) {
        return denominator / divisor;
    }
};

int main()
{
	function<int(int, int)> f1 = add;      // function pointer
	function<int(int, int)> f2 = divide(); // callable class type
	function<int(int, int)> f3 = [](int i, int j) // lambda
	                             { return i * j; };
	cout << f1(4,2) << endl; // prints 6
	cout << f2(4,2) << endl; // prints 2
	cout << f3(4,2) << endl; // prints 8

	// table of callable objects corresponding to each binary operator
	// all the callables must take two ints and return an int
	// an element can be a function pointer, function object, or lambda
	map<string, function<int(int, int)>> binops = {
		{"+", add},                  // function pointer
		{"-", std::minus<int>()},    // library function object
		{"/",  divide()},            // user-defined function object
		{"*", [](int i, int j) { return i * j; }}, // unnamed lambda
		{"%", mod} };                // named lambda object

	cout << binops["+"](10, 5) << endl; // calls add(10, 5)
	cout << binops["-"](10, 5) << endl; // uses the call operator of the minus<int> object
	cout << binops["/"](10, 5) << endl; // uses the call operator of the divide object
	cout << binops["*"](10, 5) << endl; // calls the lambda function object
	cout << binops["%"](10, 5) << endl; // calls the lambda function object

	// memp can point to either shift operation in ShiftOps
	// memp points to the Lshift member
	function<int (ShiftOps*, int, int)> memp = &ShiftOps::Lshift;

	ShiftOps shift(cout);      // declare an object to which to bind the member pointer
	binops.insert({"<<", bind(memp, &shift, _1, _2)});
	cout << binops["<<"](10, 5) << endl; // calls member function
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl; using std::ostream;

#include <map>
using std::map;

#include <string>
using std::string;

#include <functional>
using std::bind; using std::function;
using namespace std::placeholders;

// ordinary function
int add(int i, int j) { return i + j; }

// lambda, which generates an unnamed function-object class
auto mod = [](int i, int j) { return i % j; };

// function-object class
// In the first printing we named this struct div, but that name conflicts with
// the name of a C library function.  Compilers are permitted to put
// C library names in the global namespace.  Future printings will
// change the name of this calss to divide.
struct divide {
    int operator()(int denominator, int divisor) {
        return denominator / divisor;
    }
};

int main()
{
	function<int(int, int)> f1 = add;      // function pointer
	function<int(int, int)> f2 = divide(); // callable class type
	function<int(int, int)> f3 = [](int i, int j) // lambda
	                             { return i * j; };
	cout << f1(4,2) << endl; // prints 6
	cout << f2(4,2) << endl; // prints 2
	cout << f3(4,2) << endl; // prints 8

	// table of callable objects corresponding to each binary operator
	// all the callables must take two ints and return an int
	// an element can be a function pointer, function object, or lambda
	map<string, function<int(int, int)>> binops = {
		{"+", add},                  // function pointer
		{"-", std::minus<int>()},    // library function object
		{"/",  divide()},            // user-defined function object
		{"*", [](int i, int j) { return i * j; }}, // unnamed lambda
		{"%", mod} };                // named lambda object

	cout << binops["+"](10, 5) << endl; // calls add(10, 5)
	cout << binops["-"](10, 5) << endl; // uses the call operator of the minus<int> object
	cout << binops["/"](10, 5) << endl; // uses the call operator of the divide object
	cout << binops["*"](10, 5) << endl; // calls the lambda function object
	cout << binops["%"](10, 5) << endl; // calls the lambda function object

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::endl;

int main()
{
    vector<int> ivec;

    // size should be zero; capacity is implementation defined
    cout << "ivec: size: " << ivec.size()
         << " capacity: "  << ivec.capacity() << endl;

    // give ivec 24 elements
    for (vector<int>::size_type ix = 0; ix != 24; ++ix)
         ivec.push_back(ix);

    // size should be 24; capacity will be >= 24 and is implementation defined
    cout << "ivec: size: " << ivec.size()
         << " capacity: "  << ivec.capacity() << endl;
    ivec.reserve(50); // sets capacity to at least 50; might be more
    // size should be 24; capacity will be >= 50 and is implementation defined
    cout << "ivec: size: " << ivec.size()
         << " capacity: "  << ivec.capacity() << endl;

    // add elements to use up the excess capacity
    while (ivec.size() != ivec.capacity())
         ivec.push_back(0);

    // capacity should be unchanged and size and capacity are now equal
    cout << "ivec: size: " << ivec.size()
         << " capacity: "  << ivec.capacity() << endl;
    ivec.push_back(42); // add one more element

    // size should be 51; capacity will be >= 51 and is implementation defined
    cout << "ivec: size: " << ivec.size()
         << " capacity: "  << ivec.capacity() << endl;

	ivec.shrink_to_fit();  // ask for the memory to be returned

    // size should be unchanged; capacity is implementation defined
    cout << "ivec: size: " << ivec.size()
         << " capacity: "  << ivec.capacity() << endl;

return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Version_test.h"

// if the regular expression library isn't support, do nothing
#ifdef REGEX

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <string>
using std::string;

#include <regex>
using std::regex; using std::sregex_iterator; using std::smatch;
using std::regex_error;

int main()
{
	try {
		// one or more alphanumeric characters followed by a '.'
		// followed by "cpp" or "cxx" or "cc"
		regex r("[[:alnum:]]+\\.(cpp|cxx|cc)$", regex::icase);

		smatch results; // object to hold details about the match
		string filename;
		while (cin >> filename)
			if (regex_search(filename, results, r))
				cout << results.str() << endl;  // print the match
	} catch (regex_error e)
		{ cout << e.what() << " " << e.code() << endl; }

	return 0;
}

#else

// do nothing
int main() { return 0; }
#endif
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <cctype>
using std::isupper; using std::toupper;
using std::islower; using std::tolower;
using std::isalpha; using std::isspace;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	string s("Hello World!!!");
	// punct_cnt has the same type that s.size returns
	decltype(s.size()) punct_cnt = 0;

	// count the number of punctuation characters in s
	for (auto c : s)         // for every char in s
		if (ispunct(c))      // if the character is punctuation
			++punct_cnt;     // increment the punctuation counter

	cout << punct_cnt
	     << " punctuation characters in " << s << endl;

	// convert s to uppercase
	string orig = s;
	for (auto &c : s)   // for every char in s (note: c is a reference)
		// c is a reference, so this assignment changes the char in s
		c = toupper(c);
	cout << s << endl;

	// convert first word in s to uppercase
	s = orig;  // restore s to original case
	decltype(s.size()) index = 0;

	// process characters in s until we run out of characters
	// or we hit a whitespace
	while (index != s.size() && !isspace(s[index])) {

	    // s[index] returns a reference so we can change
		// the underlying character
		s[index] = toupper(s[index]);

		// increment the index to look at the next character
		// on the next iteration
		++index;
	}
	cout << s << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	string str("some string"), orig = str;
	if (!str.empty())          // make sure there's a character to print
		cout << str[0] << endl;// print the first character in str

	if (!str.empty())       // make sure there's a character in str[0]
		// assign a new value to the first character in str
		str[0] = toupper(str[0]);
	cout << str << endl;

	str = orig; // restore str to its original value

	// equivalent code using iterators instead of subscripts
	if (str.begin() != str.end()) { // make sure str is not empty
		auto it = str.begin();  // it denotes the first character in str
		*it = toupper(*it);     // make that character uppercase
	}
	cout << str << endl;

	str = orig; // restore str to its original value

	// four wasy to capitalize first word in str:
	// 1. for loop with subscripts
	for (decltype(str.size()) index = 0;
		 index != str.size() && !isspace(str[index]); ++index)
    		str[index] = toupper(str[index]); // capitalize the current character
	cout << str << endl;

	str = orig; // restore str to its original value

	// 2. for loop with iterators instead of subscripts
	for (auto it = str.begin(); it != str.end() && !isspace(*it); ++it)
		*it = toupper(*it); // capitalize the current character
	cout << str << endl;

	str = orig; // restore str to its original value

	// 3. while instead of a for with subscripts
	decltype(str.size()) index = 0; // subscript to look at characters in str
	while (index != str.size() && !isspace(str[index])) {
		str[index] = toupper(str[index]);  // capitalize the current character
		++index;        // advance the index to get the next character
	}
	cout << str << endl;

	// 4. while loop with iterators
	auto beg = str.begin();
	while (beg != str.end() && !isspace(*beg)) {
		*beg = toupper(*beg);
		++beg;
	}
	cout << str << endl;

	str = orig; // restore str to its original value

	// range for loop to process every character
	// first a loop to print the characters in str one character to a line
	for (auto c : str)      // for every char in str
		cout << c << endl;  // print the current character followed by a newline

	// next change every character in str
	for (auto &c : str)  // note: c is a reference
		c = '*';         // assign a new value to the underlying char in str
	cout << str << endl;

	str = orig;  // restore str to its original value

	// equivalent code using traditional for loops
	// first print the characters in str
	for (decltype(str.size()) ix = 0; ix != str.size(); ++ix)
		cout << str[ix] << endl;  // print current character followd by a newline

	// next change every character in str
	for (decltype(str.size()) ix = 0; ix != str.size(); ++ix)
		str[ix] = '*';  // assigns a new value to the character in str
	cout << str << endl;

	str = orig;  // restore str to its original value

	// equivalent code using traditional for loops and iterators
	// first print the characters in str
	for (auto beg = str.begin(); beg != str.end(); ++beg)
		cout << *beg << endl;  // print current character followd by a newline

	// next change every character in str
	for (auto beg = str.begin(); beg != str.end(); ++beg)
		*beg = '*';  // assigns a new value to the character in str
	cout << str << endl;
	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
 */

#include <iostream>
#include <string>

int main()
{
    std::string s;

    // ok: calls std::getline(std::istream&, const std::string&)
    getline(std::cin, s);

	std::cout << s << std::endl;

    return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <sstream>
using std::istringstream;

#include <string>
using std::string;

void read()
{
	// turns on both fail and bad bits
	cin.setstate(cin.badbit | cin.eofbit | cin.failbit);
}

void off()
{
	// turns off failbit and badbit but all other bits unchanged
	cin.clear(cin.rdstate() & ~cin.failbit & ~cin.badbit);
}


int main()
{
	cout << "before read" << endl;
	if (cin.good()) cout << "cin's good" << endl;
	if (cin.bad()) cout << "cin's bad" << endl;
	if (cin.fail()) cout << "cin's fail" << endl;
	if (cin.eof()) cout << "cin's eof" << endl;

	read();
	cout << "after read" << endl;
	if (cin.good()) cout << "cin's good" << endl;
	if (cin.bad()) cout << "cin's bad" << endl;
	if (cin.fail()) cout << "cin's fail" << endl;
	if (cin.eof()) cout << "cin's eof" << endl;

	off();
	cout << "after off" << endl;
	if (cin.good()) cout << "cin's good" << endl;
	if (cin.bad()) cout << "cin's bad" << endl;
	if (cin.fail()) cout << "cin's fail" << endl;
	if (cin.eof()) cout << "cin's eof" << endl;
	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <cstring>
using std::strcmp;

#include <iostream>
using std::cout; using std::endl;

#include "compare.h"

int main()
{
    // instantiates int compare(const int&, const int&)
    cout << compare(1, 0) << endl;       // T is int

    // instantiates int compare(const vector<int>&, const vector<int>&)
    vector<int> vec1{1, 2, 3}, vec2{4, 5, 6};
    cout << compare(vec1, vec2) << endl; // T is vector<int>

    long l1, l2;
    int i1, i2;
    compare(i1, i2);      // instantiate compare(int, int)
    compare(l1, l2);      // instantiate compare(long, long)
	compare<int>(i1, l2); // uses compare(int, int)
	compare<long>(i1, l2);// uses compare(long, long)

    const char *cp1 = "hi", *cp2 = "world";
    compare(cp1, cp2);          // calls the specialization
    compare<string>(cp1, cp2);  // converts arguments to string

    return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Sales_data.h"

#include <iostream>
using std::cout; using std::endl; using std::cin;

#include <functional>
using std::less; using std::greater;

// compare has a default template argument, less<T>
// and a default function argument, F()
template <typename T, typename F = less<T>>
int compare(const T &v1, const T &v2, F f = F())
{
	if (f(v1, v2)) return -1;
	if (f(v2, v1)) return 1;
	return 0;
}

int main()
{
	bool i = compare(0, 42); // uses less; i is -1

	// result depends on the isbns in item1 and item2
	Sales_data item1(cin), item2(cin);
	bool j = compare(item1, item2, compareIsbn);

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <functional>
using std::less;

#include <cstring>
using std::strcmp;

// version of compare that will be correct even if used on pointers
template <typename T> int compare(const T &v1, const T &v2)
{
	cout << "compare(T)" << "\t";

	if (less<T>()(v1, v2)) return -1;
	if (less<T>()(v2, v1)) return 1;

	return 0;
}

template<unsigned N, unsigned M>
int compare(const char (&p1)[N], const char (&p2)[M])
{
	cout << "compare(const char arrays)" << "\t";

	return strcmp(p1, p2);
}

template<>
int compare(const char *const& p1, const char *const& p2)
{
	cout << "compare(const char*const)" << "\t";

	return strcmp(p1, p2);
}

int main()
{
	int *p1 = new int(45);
	int *p2 = new int(42);

	// because we're comparing pointer values, the result of
    // this call may vary each time the program is run
	cout << compare(*p1, *p2) << endl;
	cout << compare(p1, p2) << endl;

	cout << strcmp("hi", "mom") << endl;
	cout << compare("hi", "mom") << endl;

	const char *cp1 = "hi", *cp2= "mom";
	cout << compare(cp1, cp2) << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
int main()
{
	// i is an int; p is a pointer to int; r is a reference to int
	int i = 1024, *p = &i, &r = i;

	// three ways to print the value of i
	std::cout << i << " " <<  *p <<  " " << r << std::endl;

	int j = 42, *p2 = &j;
	int *&pref = p2;  // pref is a reference to the pointer p2

	// prints the value of j, which is the int to which p2 points
	std::cout << *pref << std::endl;

	// pref refers to a pointer; assigning &i to pref makes p point to i
	pref = &i;
	std::cout << *pref << std::endl; // prints the value of i

	// dereferencing pref yields i, the int to which p2 points;
	*pref = 0;  // changes i to 0

	std::cout << i << " " << *pref << std::endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <string>
using std::string;

#include <vector>
using std::vector;

vector<unsigned> grades;

int main()
{
	unsigned i;
	while (cin >> i)
		grades.push_back(i);

	for (auto grade : grades) {  // for each grade in grades
		// set the initial grade as pass or fail
		string finalgrade = (grade < 60) ?  "fail" : "pass";

		finalgrade = (grade > 90) ? "high pass"
				                  : (grade < 60) ? "fail" : "pass";

		cout << grade << " " + finalgrade << endl;
	}

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
int main()
{
	int i = 42;
	std::cout << i << std::endl; // prints 42
	if (i) // condition will evaluate as true
		i = 0;
	std::cout << i << std::endl; // prints 0

	bool b = 42;            // b is true
	std::cout << b << std::endl; // prints 1

	int j = b;              // j has value 1
	std::cout << j << std::endl; // prints 1

	double pi = 3.14;       // pi has value 3.14
	std::cout << pi << std::endl; // prints 3.14

	j = pi;                 // j has value 3
	std::cout << j << std::endl; // prints 3

	unsigned char c = -1;   // assuming 8-bit chars, c has value 255
	i = c;  // the character with value 255 is an unprintable character
	        // assigns value of c (i.e., 255) to an int
	std::cout << i << std::endl; // prints 255

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <utility>
#include <iostream>

class Foo {
public:
	Foo() = default;  // default constructor needed because Foo has a copy constructor
	Foo(const Foo&);  // copy constructor
	// other members, but Foo does not define a move constructor
};

Foo::Foo(const Foo&) { std::cout << "Foo copy ctor" << std::endl; }

int main()
{
	Foo x;
	Foo y(x);            // copy constructor; x is an lvalue
	Foo z(std::move(x)); // copy constructor, because there is no move constructor
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <iostream>
using std::cout; using std::endl;

size_t count_calls()
{
	static size_t ctr = 0;  // value will persist across calls
	return ++ctr;
}

int main()
{
	for (size_t i = 0; i != 10; ++i)
		cout << count_calls() << endl;
	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include <cstring>

#include <cstddef>
using std::size_t;

int main() {
	string s1 = "A string example";
	string s2 = "A different string";

	if (s1 < s2)  // false: s2 is less than s1
		cout << s1 << endl;
	else
		cout << s2 << endl;
	const char ca1[] = "A string example";
	const char ca2[] = "A different string";

	if (strcmp(ca1, ca2) < 0) // same effect as string comparison s1 < s2
		cout << ca1 << endl;
	else
		cout << ca2 << endl;

	const char *cp1 = ca1, *cp2 = ca2;
	cout << strcmp(cp1, cp2) << endl; // output is positive
	cout << strcmp(cp2, cp1) << endl; // output is negative
	cout << strcmp(cp1, cp1) << endl; // output is zero


	cout << strlen(cp1) << endl; // prints 16; strlen ignores the null

	const unsigned sz = 16 + 18 + 2;
	char largeStr[sz];      // will hold the result
	// disastrous if we miscalculated the size of largeStr
	strcpy(largeStr, ca1);  // copies ca1 into largeStr
	strcat(largeStr, " ");  // adds a space at the end of largeStr
	strcat(largeStr, ca2);  // concatenates ca2 onto largeStr
	// prints A string example A different string
	cout << largeStr << endl;

	strncpy(largeStr, ca1, sz); // size to copy includes the null
	if (strlen(ca1) > sz)
		largeStr[sz-1] = '\0';
	strncat(largeStr, " ", 2);  // pedantic, but a good habit
	strncat(largeStr, ca2, sz - strlen(largeStr));
	cout << largeStr << endl;

	// initialize large_string as a concatenation of s1, a space, and s2
	string large_string = s1 + " " + s2;
	cout << large_string << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout;
using std::endl;

int main()
{
    int ival = 1024;
    int *pi = &ival;   // pi points to an int
    int **ppi = &pi;   // ppi points to a pointer to an int
    cout << "The value of ival\n"
         << "direct value: " << ival << "\n"
         << "indirect value: " << *pi << "\n"
         << "doubly indirect value: " << **ppi
         << endl;

	int i = 2;
	int *p1 = &i;     // p1 points to i
	*p1 = *p1 * *p1;  // equivalent to i = i * i
	cout << "i  = " << i << endl;

	*p1 *= *p1;       // equivalent to i *= i
	cout << "i  = " << i << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "debug_rep.h"

#include <string>
using std::string;

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	vector<int> v = {1,2,3,4,5,6,7,8,9};
	string s("hi");
	cout << debug_rep(v) << endl;
	cout << debug_rep(s) << endl;
	cout << debug_rep("hi") << endl;
	cout << debug_rep(&v[0]) << endl;
	cout << debug_rep(&s) << endl;
	const string *sp = &s;
	cout << debug_rep(sp) << endl;

	char carr[] = "bye";            // calls pointer version if no overloads
	cout << debug_rep(carr) << endl;
	vector<string> authors = {"Proust", "Shakespeare", "Barth"};
	vector<const char*> authors2 = {"Proust", "Shakespeare", "Barth"};
	cout << debug_rep(authors) << endl;
	cout << debug_rep(authors2) << endl;
	cout << debug_rep(s) << endl;
	s += "more stuff";
	cout << debug_rep(s) << endl;
	s += "\\escape\"and quotes";
	cout << debug_rep(s) << endl;

	cout << debug_rep("hi world!") << endl; // calls debug_rep(T*)

	s = "hi";
	const char *cp = "bye";
	char arr[] = "world";

	cout << debug_rep(s) << endl;  // calls specialization debug_rep(const string&
	cout << debug_rep(cp) << endl; // calls specialization debug_rep(const char*
	cout << debug_rep(arr) << endl;// calls specialization debug_rep(char*
	cout << debug_rep(&s) << endl; // calls template debug_rep(T*)

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Debug.h"
// only implementation for the Debug classes are definitions
// for static members named enable
constexpr Debug HW_Subsystem::enable;
constexpr Debug IO_Subsystem::enable;
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

int main()
{
	int a = 0;
	decltype(a) c = a;   // c is an int
	decltype((a)) d = a; // d is a reference to a
	++c;                 // increments c, a (and d) unchanged
	cout << "a: " << a << " c: " << c << " d: " << d << endl;
	++d;                 // increments a through the reference d
	cout << "a: " << a << " c: " << c << " d: " << d << endl;

	int A = 0, B = 0;
	decltype((A)) C = A;   // C is a reference to A
	decltype(A = B) D = A; // D is also a reference to A
	++C;
	cout << "A: " << A << " C: " << C << " D: " << D << endl;
	++D;
	cout << "A: " << A << " C: " << C << " D: " << D << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Sales_data.h"

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

int main()
{
	Sales_data data1, data2;
	std::cin >> data1 >> data2;    // read Sales_data transactions
	cout << data1 + data2 << endl; // write sum of Sales_data objects
	cout << 42 + 5 << endl;        // write sum of ints

	// equivalent calls to a nonmember operator function
	data1 + data2;            // normal expression
	operator+(data1, data2);  // equivalent function call
	cout << operator+(data1, data2) << endl;

	data1 += data2;           // expression-based ``call''
	data1.operator+=(data2);  // equivalent call to a member operator function
	cout << data1 << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <string>
using std::string;

int main()
{
    // repeatedly ask the user for a pair of numbers to sum
    string rsp;  // used in the condition; can't be defined inside the do
    do {
        cout << "please enter two values: ";
        int val1 = 0, val2 = 0;
        cin  >> val1 >> val2;
        cout << "The sum of " << val1 << " and " << val2
             << " = " << val1 + val2 << "\n\n"
             << "More? Enter yes or no: ";
        cin  >> rsp;
    } while (!rsp.empty() && rsp[0] != 'n');

	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <typeinfo>
using std::bad_cast;

#include <iostream>
using std::cout; using std::endl;

struct A { virtual ~A() { } };
struct B : virtual public A { /* . . . */ };
struct C : public B { /* . . . */ };
struct D : public B, virtual public A { /* . . . */ };

void exercises() {
	A *pa = new C;
    if (B *pb = dynamic_cast< B* >(pa))
         cout << "cast from C to B* ok" << endl;
    else
         cout << "cast from C to B* not ok" << endl;
	B *pb = new B;
    if (C *pc = dynamic_cast< C* >(pb))
         cout << "cast from B to C* ok" << endl;
    else
         cout << "cast from B to C* not ok" << endl;

	A *pc = new C;
    if (B *pb = dynamic_cast< B* >(pc))
         cout << "cast C to B* ok" << endl;
    else
         cout << "cast C to B* not ok" << endl;

	A *pd = new D;
    if (B *pb = dynamic_cast< B* >(pd))
         cout << "cast D to B* ok" << endl;
    else
         cout << "cast D to B* not ok" << endl;
}

struct Base {
   virtual ~Base() {};
};

struct Derived: public Base { };

void cast_to_ref(const Base &b)
{
    try {
        const Derived &d = dynamic_cast<const Derived&>(b);
	// use the Derived object to which b referred
    } catch (bad_cast) {
        cout << "called f with an object that is not a Derived" << endl;
    }
}

int main()
{
	Base *bp;
	bp = new Derived;  // bp actually points to a Derived object
	if (Derived *dp = dynamic_cast<Derived*>(bp))
	{
	    // use the Derived object to which dp points
	} else {  // bp points at a Base object
    	// use the Base object to which bp points
	}

	exercises();

	cast_to_ref(*bp);
	cast_to_ref(Base());
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::sort; using std::for_each;

#include <functional>
using std::bind;
using namespace std::placeholders;

#include <string>
using std::string;

#include <vector>
using std::vector;

#include <iostream>
using std::cin; using std::cout; using std::endl;

// comparison function to be used to sort by word length
bool isShorter(const string &s1, const string &s2)
{
    return s1.size() < s2.size();
}

bool LT(const string &s1, const string &s2)
{
	return s1 < s2;
}

void print(const vector<string> &words)
{
	for_each(words.begin(), words.end(),
	        [](const string &s) { cout << s << " "; });
	cout << endl;
}

int main()
{
    vector<string> words;

    // copy contents of each book into a single vector
    string next_word;
    while (cin >> next_word) {
        // insert next book's contents at end of words
        words.push_back(next_word);
    }
	print(words);

	vector<string> cpy = words; // save the original data

	// uses string < to compare elements
	// sort and print the vector
	sort(words.begin(), words.end());

	words = cpy;  // return to the original data
	// uses the LT function to compare elements
	// should have the same output as the previous sort
	sort(words.begin(), words.end(), LT);
    print(words);

	words = cpy;  // return to the original data

	// eliminate duplicates
	sort(words.begin(), words.end());
	auto it = unique(words.begin(), words.end());
	words.erase(it, words.end());

	// sort by length using a function
	stable_sort(words.begin(), words.end(), isShorter);
    print(words);

	words = cpy; // return to the original data
	// sort the original input on word length, shortest to longest
	sort(words.begin(), words.end(), isShorter);
    print(words);

	// use bind to invert isShorter to sort longest to shortest
	sort(words.begin(), words.end(), bind(isShorter, _2, _1));
    print(words);

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

// unscoped enumeration; the underlying type is machine dependent
enum Tokens {INLINE = 128, VIRTUAL = 129};

void ff(Tokens)
{
	cout << "ff(Tokens)" << endl;
}
void ff(int)
{
	cout << "ff(int)" << endl;
}
void newf(int)
{
	cout << "newf(int)" << endl;
}
void newf(unsigned char)
{
	cout << "newf(unsigned char)" << endl;
}

int main() {
    Tokens curTok = INLINE;
    ff(128);    // exactly matches ff(int)
    ff(INLINE); // exactly matches ff(Tokens)
    ff(curTok); // exactly matches ff(Tokens)

	void newf(unsigned char);
	void newf(int);
	unsigned char uc = VIRTUAL;

	newf(VIRTUAL);  // calls newf(int)
	newf(uc);       // calls newf(unsigned char)

	newf(129);      // calls newf(int)

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <cstddef>
using std::size_t;

// forward declaration of unscoped enum named intValues
enum intValues : unsigned long long; // unscoped, must specify a type
enum class open_modes;  // scoped enums can use int by default

enum class open_modes {input, output, append};

// input is an enumerator of open_modes
open_modes om = open_modes::input;

enum class intTypes {
	charTyp = 8, shortTyp = 16, intTyp = 16,
	longTyp = 32, long_longTyp = 64
};

constexpr intTypes charbits = intTypes::charTyp;

enum intValues : unsigned long long {
	charTyp = 255, shortTyp = 65535, intTyp = 65535,
	longTyp = 4294967295UL,
	long_longTyp = 18446744073709551615ULL
};

int main()
{
	enum color {red, yellow, green};      // unscoped enumeration
	enum class peppers {red, yellow, green}; // enumerators are hidden

	// unnamed, unscoped enum
	enum {floatPrec = 6, doublePrec = 10, double_doublePrec = 10};

	// enumerators are in scope for an unscoped enumeration
	color eyes = green;

	color hair = color::red;   // we can explicitly access the enumerators
	peppers p2 = peppers::red; // using red from peppers

	int i = color::red;   // unscoped enumerator implicitly converted to int

	// point2d is 2, point2w is 3, point3d is 3, point3w is 4
	enum class Points { point2d = 2, point2w,
	                    point3d = 3, point3w };

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::equal;

#include <list>
using std::list;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	list<const char *> roster1;
	vector<string> roster2;
	roster2 = {"hello", "so long", "tata"};
	roster1 = {"hello", "so long"};

	auto b =
	// roster2 should have at least as many elements as roster1
	equal(roster1.cbegin(), roster1.cend(), roster2.cbegin());

	(b) ? cout << "true" : cout << "false";
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iterator>
using std::istream_iterator;

#include <vector>
using std::vector;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main() {
	// use istream_iterator to initialize a vector
	istream_iterator<int> in_iter(cin), eof;
	vector<int> vec(in_iter, eof);

	for (auto it : vec)
		cout << it << " ";
	cout << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::find;

#include <string>
using std::string;

#include <list>
using std::list;

#include <vector>
using std::vector;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	list<string> slist;
	string s;
	while (cin >> s)
		slist.push_back(s);  // read the contents into slist

	/* we'll explain find in chapter 10
	 * find looks in the sequence denoted by its first two
	 * iterator arguments for the value of its third argument
	 * returns an iterator to the first element with that value
	 * if that element exists in the input sequence
	 * otherwise returns the end iterator
	*/
	auto iter = find(slist.begin(), slist.end(), "Quasimodo");
	if (iter != slist.end())
	     slist.erase(iter);

	auto orig = slist; // keep a copy before we destroy the contents
	slist.clear();     // delete all the elements within the container
	cout << "after clear, size is: " << slist.size() << endl;

	slist = orig; // restore the data
	slist.erase(slist.begin(), slist.end()); // equivalent
	cout << "after erase begin to end, size is: " << slist.size() << endl;

	slist = orig; // restore the data
	auto elem1 = slist.begin(), elem2 = slist.end();
	// delete the range of elements between two iterators
	// returns an iterator to the element just after the last removed element
	elem1 = slist.erase(elem1, elem2); // after the call elem1 == elem2
	cout << "after erase elem1 to elem2 size is: " << slist.size() << endl;

	if (elem1 != elem2)
		cout << "somethings wrong" << endl;
	else
		cout << "okay, they're equal " << endl;

}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::find;

#include <string>
using std::string;

#include <list>
using std::list;

#include <forward_list>
using std::forward_list;

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	// lst has ten elements 0 ... 9 in value
	list<int> lst = {0,1,2,3,4,5,6,7,8,9};

	// print the initial values in lst
	cout << "initial list: ";
	for (auto it : lst)
		cout << it << " ";
	cout << endl;

	// erase the odd elements in lst
	auto it = lst.begin();
	while (it != lst.end())
		if (*it % 2)             // if the element is odd
			it = lst.erase(it);  // erase this element
		else
			++it;

	// print the current contents of lst
	cout << "after erasing odd elements from lst: ";
	for (auto it : lst)
		cout << it << " ";
	cout << endl;

	// repeat the same actions but on a forward_list
	forward_list<int> flst = {0,1,2,3,4,5,6,7,8,9};

	// print the initial values in flst
	cout << "initial list: ";
	for (auto it : flst)
		cout << it << " ";
	cout << endl;

	// erase the odd elements in flst
	auto prev = flst.before_begin(); // element "off the start" of flst
	auto curr = flst.begin();     // denotes the first element in flst
	while (curr != flst.end()) {  // while there are still elements
		if (*curr % 2)                     // if the element is odd
	    	curr = flst.erase_after(prev); // erase it and move curr
		else {
			prev = curr; // move the iterators to denote the next
			++curr;      // element and one before the next element
		}
	}

	// print the current contents of lst
	cout << "after erasing elements from flst: ";
	for (auto it : flst)
		cout << it << " ";
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <map>
using std::map;

#include <string>
using std::string;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
    map<string, size_t> word_count;  // empty map from string to size_t
    string word;
    while (cin >> word)
      ++word_count[word];

	string removal_word = "the";

	// two ways to remove an entry from a map
	// 1. by key
	// erase on a key returns the number of elements removed
	if (word_count.erase(removal_word))
	     cout << "ok: " << removal_word << " removed\n";
	else cout << "oops: " << removal_word << " not found!\n";

	// 2. by removing an iterator to the element we want removed
	removal_word = "The";  // strings are case sensitive
	map<string,size_t>::iterator where;
	where = word_count.find(removal_word);  // should be gone

	if (where == word_count.end())
	     cout << "oops: " << removal_word << " not found!\n";
	else {
	     word_count.erase(where);   // erase iterator returns void
	     cout << "ok: " << removal_word << " removed!\n";
	}
	    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include <initializer_list>
using std::initializer_list;

#include <sstream>
using std::ostringstream;

// chapter 7 will explain the code used in defining ErrCode
struct ErrCode {
	ErrCode(int i) : num(i) { }  // initializes objects of type ErrCode
	string msg()                 // member function of ErrCode
	{ ostringstream s; s << "ErrCode " << num; return s.str(); }
	int num;  // data member, note uninitialized
};

// version that takes an ErrCode and a list of strings
void error_msg(ErrCode e, initializer_list<string> il)
{
	cout << e.msg() << ": ";
	for (const auto &elem : il)
		cout << elem << " " ;
	cout << endl;
}

// overloaded version takes only a list of strings
void error_msg(initializer_list<string> il)
{
	for (auto beg = il.begin(); beg != il.end(); ++beg)
		cout << *beg << " " ;
	cout << endl;
}

// function to illustrate list initializing return value
vector<string> functionX()
{
	string expected = "description", actual = "some other case";
	// . . .
	if (expected.empty())
		return {};  // return an empty vector
	else if (expected == actual)
		return {"functionX", "okay"}; // return list-initialized vector
	else
		return {"functionX", expected, actual};
}

int main()
{
	string expected = "description", actual = "some other case";
	initializer_list<int> li = {0,1,2,3};

	// expected, actual are strings
	if (expected != actual)
		error_msg({"functionX", expected, actual});
	else
		error_msg({"functionX", "okay"});

	// expected, actual are strings
	if (expected != actual)
		error_msg(ErrCode(42), {"functionX", expected, actual});
	else
		error_msg(ErrCode(0), {"functionX", "okay"});

	// can pass an empty list, calls second version of error_msg
	error_msg({}); // prints blank line

	// call function that list initializes its return value
	// results is a vector<string>
	auto results = functionX();
	for (auto i : results)
		cout << i << " ";
	cout << endl;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>

int main() {
	std::cout << '\n';       // prints a newline
	std::cout << "\tHi!\n";  // prints a tab followd by "Hi!" and a newline
	std::cout << "Hi \x4dO\115!\n"; // prints Hi MOM! followed by a newline
	std::cout << '\115' << '\n';    // prints M followed by a newline

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

namespace primerLib {
    void compute() { cout << "primerLib::compute()" << endl; }
    void compute(const void *)
	   { cout << "primerLib::compute(const void *)" << endl; }
}

// brings comput() and compute(const void*) into scope
using primerLib::compute;

void compute(int) { cout << "compute(int)" << endl; }
void compute(double, double = 3.4)
	   { cout << "compute(double, double)" << endl; }
void compute(char*, char* = 0)
         { cout << "compute(char*, char*)" << endl; }

int main()
{
	int i = 42;
	char c = 'a';
	compute(i);  // compute(int)
	compute(c);  // compute(int)
	compute(&i); // primerLib::compute(const void*)
	compute(&c); // compute(char*, char*)
	compute(3.4);// compute(double, double)

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

template <typename T>
T accum(const T &t)
{
	return t;
}

template <typename T, typename... Args>
T accum(const T &t, Args... args)
{
	return t + accum(args...);
}

// h adds its variadic arguments to the starting value of 42
int h()
{
	return 42; // starting point for the accumulation
}

template <typename ...Args> int h(int t, Args ... args)
{
	return t + h(args...); // sum of all the values in args plus 42
}

// produces the sum of up to 4 integral values
void f(int i, int j = 0, int k = 0, int l = 0)
{
	cout << i << " + "
	     << j << " + "
	     << k << " + "
	     << l << " =  "
	     << i + j + k + l << endl;
}

// expansion: applies the pattern to each member of the pack
//            using a separator appropriate to the context
template<typename ... Args> void g(Args ... args) {
	cout << sizeof...(Args) << endl;  // number of type parameters
	cout << sizeof...(args) << endl;  // number of function parameters
	// call f passing it the arguments from args
	f(args...);                // f(a1, a2, a3, ..., an)

	// call h passing it the arguments from args
	cout << h(args...) << endl; // h(a1, a2, a3, ..., an)

	// the pattern is h(x),
	// the expansion calls h on each argument in args
	f(h(args) ...);            // f(h(a1), h(a2), h(a3), ..., h(an))

	// args is expanded in the call to h
	f(h(args ...));            // f(h(a1, a2, a3, ..., an2)

	// pattern adds the argument value to result from calling h(5,6,7,8)
	f(h(5,6,7,8 ) + args ...); // f(h(5,6,7,8) + a1, h(5,6,7,8) + a2,
	                           //   h(5,6,7,8) + a3, ..., h(5,6,7,8) + an)
}

int main()
{
	cout << accum(1,2,3,4) << endl;

	g(1,2,3,4);

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

// declarations of our factorial functions
// definitions are in LocalMath.cc
#include "LocalMath.h"

int main()
{
	cout << factorial(5) << endl;
	cout << fact(5) << endl;
	cout << factorial(0) << endl;
	cout << fact(0) << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <functional>
using std::plus; using std::negate;
using std::function; using std::placeholders::_1;
using std::bind; using std::less_equal;

#include <iostream>
using std::cout; using std::endl;

#include <algorithm>
using std::count_if;

#include <vector>
using std::vector;

#include <iostream>
using std::cin;

#include <string>
using std::string;

bool size_compare(const string &s, string::size_type sz)
{
    return s.size() >= sz;
}

int main() {

	cout << plus<int>()(3,4) << endl; // prints 7

	plus<int> intAdd;      // object that can add two int values
	negate<int> intNegate; // object that can negate an int value

	// uses intAdd::operator(int, int) to add 10 and 20
	int sum = intAdd(10, 20);         // equivalent to sum = 30
	cout << sum << endl;

	sum = intNegate(intAdd(10, 20));  // equivalent to sum = -30
	cout << sum << endl;

	// uses intNegate::operator(int) to generate -10
	// as the second argument to intAdd::operator(int, int)
	sum = intAdd(10, intNegate(10));  // sum = 0

	cout << sum << endl;

	vector<int> vec = {0,1,2,3,4,5,16,17,18,19};

	// bind second argument to less_equal
	cout << count_if(vec.begin(), vec.end(),
		             bind(less_equal<int>(), _1, 10));
	cout << endl;

	vector<string> svec;
	string in;
	while (cin >> in)
		svec.push_back(in);

	function<decltype(size_compare)> fp1 = size_compare;

	//decltype(fp1)::result_type ret;
	function<bool(const string&)> fp2 = bind(size_compare, _1, 6);
	cout << count_if(svec.begin(), svec.end(), fp2)
	     << endl;
	cout << count_if(svec.begin(), svec.end(),
	                 bind(size_compare, _1, 6))
	     << endl;


	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

// declarations (not strictly speaking necessary in this file)
string::size_type sumLength(const string&, const string&);
string::size_type largerLength(const string&, const string&);

// definition of these functions
string::size_type sumLength(const string &s1, const string &s2)
{
	return s1.size() + s2.size();
}

string::size_type largerLength(const string &s1, const string &s2)
{
	return (s1.size() > s2.size()) ? s1.size() : s2.size();
}

// depending on the value of its string parameter,
// getFcn returns a pointer to sumLength or to largerLength

// three ways to declare getFcn
// 1. use decltype for the return type,
//    remembering to add a * to indicate that getFcn returns a pointer
decltype(sumLength) *getFcn(const string &);

// use trailing return type
auto getFcn(const string&) -> string::size_type(*)(const string&, const string&);

// direct definition
string::size_type (*getFcn(const string&))(const string&, const string&);

// define getFcn
decltype(sumLength)*
getFcn(const string &fetch)
{
	if (fetch == "sum")
		return sumLength;
	return largerLength;
}

int main()
{
	// "sum" is the argument to getFcn
	// ("hello", "world!") are arguments to the function getFcn returns
	cout << getFcn("sum")("hello", "world!") << endl;    // prints 11
	cout << getFcn("larger")("hello", "world!") << endl; // prints 6

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cerr; using std::cout; using std::endl;

#include <fstream>
using std::ifstream;

#include <string>
using std::string;

#include <stdexcept>
using std::runtime_error;

void process(ifstream &is)
{
	string s;
	while (is >> s)
		cout << s << endl;
}

int main(int argc, char* argv[])
{
	// for each file passed to the program
	for (auto p = argv + 1; p != argv + argc; ++p) {
	    ifstream input(*p);   // create input and open the file
	    if (input) {          // if the file is ok, ``process'' this file
	        process(input);
		} else
	        cerr << "couldn't open: " + string(*p);
	} // input goes out of scope and is destroyed on each iteration

	auto p = argv + 1, end = argv + argc;

	ifstream input;
	while (p != end) {        // for each file passed to the program
		input.open(*p);       // open the file, automatically clears the stream
	    if (input) {          // if the file is ok, read and ``process'' the input
	        	process(input);
		} else
			cerr << "couldn't open: " + string(*p);
	    input.close();        // close file when we're done with it
	    ++p;                  // increment pointer to get next file
	}
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

int main()
{
    string name("AnnaBelle");
    auto pos1 = name.find("Anna"); // pos1 == 0
    cout << pos1 ;
    string lowercase("annabelle");
    pos1 = lowercase.find("Anna");   // pos1 == npos
    cout << " " << pos1 << endl;
    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cassert>
#include <utility>
using std::pair;

#include <string>
using std::string;

#include <tuple>
using std::tuple; using std::get;
using std::make_tuple;

#include <vector>
using std::vector;

#include <numeric>
using std::accumulate;

#include <algorithm>
using std::equal_range;

#include <exception>
#include <stdexcept>
using std::domain_error;

#include <iostream>
using std::ostream; using std::istream;
using std::cout; using std::endl;

#include <fstream>
using std::ifstream;

#include "Sales_data.h"

bool lt(const Sales_data &lhs, const Sales_data &rhs)
{
	return lhs.isbn() < rhs.isbn();
}

// need to leave this for as a traditional for loop because we
// use the iterator to compute an index
// matches has three members: an index of a store and iterators into that store's vector
typedef tuple<vector<Sales_data>::size_type,
              vector<Sales_data>::const_iterator,
              vector<Sales_data>::const_iterator> matches;

// files holds the transactions for every store
// findBook returns a vector with an entry for each store that sold the given book
vector<matches>
findBook(const vector<vector<Sales_data>> &files,
         const string &book)
{
	vector<matches> ret;  // initially empty
	// for each store find the range of matching books, if any
	for (auto it = files.cbegin(); it != files.cend(); ++it) {
		// find the range of Sales_data that have the same ISBN
		auto found = equal_range(it->cbegin(), it->cend(),
		                         book, compareIsbn);
		if (found.first != found.second)  // this store had sales
			// remember the index of this store and the matching range
			ret.push_back(make_tuple(it - files.cbegin(),
                                  found.first, found.second));
	}
	return ret; // empty if no matches found
}

vector<Sales_data> build_store(const string &s)
{
	Sales_data item;
	vector<Sales_data> ret;
	ifstream is(s);
	while (read(is, item))
		ret.push_back(item);
	sort (ret.begin(), ret.end(), lt);  // need sort for equal_range to work
	return ret;
}

void reportResults(istream &in, ostream &os,
                   const vector<vector<Sales_data>> &files)
{
	string s;   // book to look for
	while (in >> s) {
		auto trans = findBook(files, s);  // stores that sold this book
		if (trans.empty()) {
			cout << s << " not found in any stores" << endl;
			continue;  // get the next book to look for
		}
		for (const auto &store : trans)   // for every store with a sale
			// get<n> returns the specified member from the tuple in store
			os << "store " << get<0>(store) << " sales: "
			   << accumulate(get<1>(store), get<2>(store),
			                 Sales_data(s))
			   << endl;
	}
}

int main(int argc, char **argv)
{
	assert(argc > 1);
	// each element in files holds the transactions for a particular store
	vector<vector<Sales_data>> files;
	for (int cnt = 1; cnt != argc; ++cnt)
		files.push_back(build_store(argv[cnt]));

	ifstream in("../data/findbook.in");  // ISBNs to search for
	reportResults(in, cout, files);
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	string numbers("0123456789"), name("r2d2");
	// returns 1, i.e., the index of the first digit in name
	auto pos = name.find_first_of(numbers);
	if (pos != string::npos)
		cout << "found number at index: " << pos
		     << " element is " << name[pos] << endl;
	else
		cout << "no number in: " << name << endl;

	pos = 0;
	// each iteration finds the next number in name
	while ((pos = name.find_first_of(numbers, pos))
	              != string::npos) {
	    cout << "found number at index: " << pos
	         << " element is " << name[pos] << endl;

	    ++pos; // move to the next character
	}

	string river("Mississippi");

	auto first_pos = river.find("is");  // returns 1
	auto last_pos = river.rfind("is");  // returns 4
	cout << "find returned: " << first_pos
	     << " rfind returned: " << last_pos << endl;

	string dept("03714p3");
	// returns 5, which is the index to the character 'p'
	pos = dept.find_first_not_of(numbers);
	cout << "first_not returned: " << pos << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <utility>
#include <iostream>
using std::cout; using std::endl;

// template that takes a callable and two parameters
// and calls the given callable with the parameters ``flipped''
template <typename F, typename T1, typename T2>
void flip(F f, T1 &&t1, T2 &&t2)
{
	f(std::forward<T2>(t2), std::forward<T1>(t1));
}

void f(int v1, int &v2)  // note v2 is a reference
{
	cout << v1 << " " << ++v2 << endl;
}

void g(int &&i, int& j)
{
	cout << i << " " << j << endl;
}

// flip1 is an incomplete implementation: top-level const and references are lost
template <typename F, typename T1, typename T2>
void flip1(F f, T1 t1, T2 t2)
{
	f(t2, t1);
}

template <typename F, typename T1, typename T2>
void flip2(F f, T1 &&t1, T2 &&t2)
{
	f(t2, t1);
}

int main()
{
	int i = 0, j = 0, k = 0, l = 0;
	cout << i << " " << j << " " << k << " " << l << endl;

	f(42, i);        // f changes its argument i
	flip1(f, j, 42); // f called through flip1 leaves j unchanged
	flip2(f, k, 42); // ok: k is changed
	g(1, i);
	flip(g, i, 42);  // ok: rvalue-ness of the third argument is preserved
	cout << i << " " << j << " " << k << " " << l << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <utility>
// for move, we don't supply a using declaration for move

#include <iostream>
using std::cerr; using std::endl;

#include <set>
using std::set;

#include <string>
using std::string;

#include "Folder.h"

void swap(Message &lhs, Message &rhs)
{
	using std::swap;  // not strictly needed in this case, but good habit

	// remove pointers to each Message from their (original) respective Folders
	for (auto f: lhs.folders)
		f->remMsg(&lhs);
	for (auto f: rhs.folders)
		f->remMsg(&rhs);

	// swap the contents and Folder pointer sets
	swap(lhs.folders, rhs.folders);   // uses swap(set&, set&)
	swap(lhs.contents, rhs.contents); // swap(string&, string&)

	// add pointers to each Message to their (new) respective Folders
	for (auto f: lhs.folders)
		f->addMsg(&lhs);
	for (auto f: rhs.folders)
		f->addMsg(&rhs);
}

Folder::Folder(Folder &&f)
{
	move_Messages(&f);   // make each Message point to this Folder
}

Folder& Folder::operator=(Folder &&f)
{
	if (this != &f) {
		remove_from_Msgs();  // remove this Folder from the current msgs
		move_Messages(&f);   // make each Message point to this Folder
	}
	return *this;
}

void Folder::move_Messages(Folder *f)
{
	msgs = std::move(f->msgs); // move the set from f to this Folder
	f->msgs.clear(); // ensure that destroying f is harmless
	for (auto m : msgs) {  // for each Message in this Folder
		m->remFldr(f);     // remove the pointer to the old Folder
		m->addFldr(this);  // insert pointer to this Folder
	}
}

Message::Message(Message &&m): contents(std::move(m.contents))
{
	move_Folders(&m); // moves folders and updates the Folder pointers
}

Message::Message(const Message &m):
    contents(m.contents), folders(m.folders)
{
    add_to_Folders(m); // add this Message to the Folders that point to m
}

Message& Message::operator=(Message &&rhs)
{
	if (this != &rhs) {       // direct check for self-assignment
		remove_from_Folders();
		contents = std::move(rhs.contents); // move assignment
		move_Folders(&rhs); // reset the Folders to point to this Message
	}
    return *this;
}

Message& Message::operator=(const Message &rhs)
{
	// handle self-assignment by removing pointers before inserting them
    remove_from_Folders();    // update existing Folders
    contents = rhs.contents;  // copy message contents from rhs
    folders = rhs.folders;    // copy Folder pointers from rhs
    add_to_Folders(rhs);      // add this Message to those Folders
    return *this;
}

Message::~Message()
{
    remove_from_Folders();
}

// move the Folder pointers from m to this Message
void Message::move_Folders(Message *m)
{
	folders = std::move(m->folders); // uses set move assignment
	for (auto f : folders) {  // for each Folder
		f->remMsg(m);    // remove the old Message from the Folder
		f->addMsg(this); // add this Message to that Folder
	}
	m->folders.clear();  // ensure that destroying m is harmless
}

// add this Message to Folders that point to m
void Message::add_to_Folders(const Message &m)
{
	for (auto f : m.folders) // for each Folder that holds m
        f->addMsg(this); // add a pointer to this Message to that Folder
}

// remove this Message from the corresponding Folders
void Message::remove_from_Folders()
{
	for (auto f : folders)  // for each pointer in folders
		f->remMsg(this);    // remove this Message from that Folder
	folders.clear();        // no Folder points to this Message

}

void Folder::add_to_Messages(const Folder &f)
{
	for (auto msg : f.msgs)
		msg->addFldr(this);   // add this Folder to each Message
}

Folder::Folder(const Folder &f) : msgs(f.msgs)
{
    add_to_Messages(f);  // add this Folder to each Message in f.msgs
}

Folder& Folder::operator=(const Folder &f)
{
    remove_from_Msgs();  // remove this folder from each Message in msgs
	msgs = f.msgs;       // copy the set of Messages from f
    add_to_Messages(f);  // add this folder to each Message in msgs
    return *this;
}

Folder::~Folder()
{
    remove_from_Msgs();
}


void Folder::remove_from_Msgs()
{
    while (!msgs.empty())
        (*msgs.begin())->remove(*this);
}
void Message::save(Folder &f)
{
    folders.insert(&f); // add the given Folder to our list of Folders
    f.addMsg(this);     // add this Message to f's set of Messages
}

void Message::remove(Folder &f)
{
    folders.erase(&f); // take the given Folder out of our list of Folders
    f.remMsg(this);    // remove this Message to f's set of Messages
}

void Folder::save(Message &m)
{
    // add m and add this folder to m's set of Folders
    msgs.insert(&m);
    m.addFldr(this);
}

void Folder::remove(Message &m)
{
    // erase m from msgs and remove this folder from m
    msgs.erase(&m);
    m.remFldr(this);
}

void Folder::debug_print()
{
    cerr << "Folder contains " << msgs.size() << " messages" << endl;
    int ctr = 1;
    for (auto m : msgs) {
        cerr << "Message " << ctr++ << ":\n\t" << m->contents << endl;
	}
}

void Message::debug_print()
{
    cerr << "Message:\n\t" << contents << endl;
    cerr << "Appears in " << folders.size() << " Folders" << endl;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include "Folder.h"

int main()
{
	string s1("contents1");
	string s2("contents2");
	string s3("contents3");
	string s4("contents4");
	string s5("contents5");
	string s6("contents6");

	// all new messages, no copies yet
	Message m1(s1);
	Message m2(s2);
	Message m3(s3);
	Message m4(s4);
	Message m5(s5);
	Message m6(s6);

	Folder f1;
	Folder f2;

	m1.save(f1); m3.save(f1); m5.save(f1);
	m1.save(f2);
	m2.save(f2); m4.save(f2); m6.save(f2);

	m1.debug_print();
	f2.debug_print();

	// create some copies
	Message c1(m1);
	Message c2(m2), c4(m4), c6(m6);

	m1.debug_print();
	f2.debug_print();

	// now some assignments
	m2 = m3;
	m4 = m5;
	m6 = m3;
	m1 = m5;

	m1.debug_print();
	f2.debug_print();

	// finally, self-assignment
	m2 = m2;
	m1 = m1;

	m1.debug_print();
	f2.debug_print();

	vector<Message> vm;
	cout << "capacity: " << vm.capacity() << endl;
	vm.push_back(m1);

	cout << "capacity: " << vm.capacity() << endl;
	vm.push_back(m2);

	cout << "capacity: " << vm.capacity() << endl;
	vm.push_back(m3);

	cout << "capacity: " << vm.capacity() << endl;
	vm.push_back(m4);

	cout << "capacity: " << vm.capacity() << endl;
	vm.push_back(m5);

	cout << "capacity: " << vm.capacity() << endl;
	vm.push_back(m6);

	vector<Folder> vf;
	cout << "capacity: " << vf.capacity() << endl;
	vf.push_back(f1);

	cout << "capacity: " << vf.capacity() << endl;
	vf.push_back(f2);

	cout << "capacity: " << vf.capacity() << endl;
	vf.push_back(Folder(f1));

	cout << "capacity: " << vf.capacity() << endl;
	vf.push_back(Folder(f2));

	cout << "capacity: " << vf.capacity() << endl;
	vf.push_back(Folder());

	Folder f3;
	f3.save(m6);
	cout << "capacity: " << vf.capacity() << endl;
	vf.push_back(f3);


	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>

int main()
{
    int sum = 0;

    // sum values from 1 through 10 inclusive
    for (int val = 1; val <= 10; ++val)
        sum += val;  // equivalent to sum = sum + val
    std::cout << "Sum of 1 to 10 inclusive is "
              << sum << std::endl;
    return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
int main()
{
	int sum = 0;
	for (int i = -100; i <= 100; ++i)
    	sum += i;
	std::cout << sum << std::endl;
	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <random>
using std::default_random_engine;
using std::bernoulli_distribution;

#include <iostream>
using std::cin; using std::cout; using std::endl;

bool play(bool player) { return player; }
int main()
{
	string resp;
	// distributions and engines have state,
    // they must be defined outside the loop!
	default_random_engine e;

	// 50/50 odds by default
	bernoulli_distribution b(0.55); // give the house a slight edge

	do {
		bool first = b(e);    // if true, the program will go first
		cout << (first ? "We go first"
	                   : "You get to go first") << endl;
		// play the game passing the indicator of who goes first
		cout << ((play(first)) ? "sorry, you lost"
	                           : "congrats, you won") << endl;
		cout << "play again? Enter 'yes' or 'no'" << endl;
	} while (cin >> resp && resp[0] == 'y');

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <cstdio> // for EOF

int main()
{
	int ch;    // use an int, not a char to hold the return from get()

	// loop to read and write all the data in the input
	while ((ch = cin.get()) != EOF)
         	cout.put(ch);
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string; using std::getline;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	string line;

	// read input a line at a time until end-of-file
	while (getline(cin, line))
		cout << line << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	char ch;
	while (cin.get(ch))
        cout.put(ch);
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Query.h"
#include "TextQuery.h"

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::cin;

#include <fstream>
using std::ifstream;

#include <stdexcept>
using std::runtime_error;

// these functions are declared in Query.h
TextQuery get_file(int argc, char **argv)
{
    // get a file to read from which user will query words
	ifstream infile;
	if (argc == 2)
    	infile.open(argv[1]);
    if (!infile) {
        throw runtime_error("No input file!");
    }

    return TextQuery(infile);  // builds query map
}

bool get_word(string &s1)
{
    cout << "enter a word to search for, or q to quit: ";
    cin >> s1;
    if (!cin || s1 == "q") return false;
    else return true;
}

bool get_words(string &s1, string &s2)
{

    // iterate with the user: prompt for a word to find and print results
    cout << "enter two words to search for, or q to quit: ";
    cin  >> s1;

    // stop if hit eof on input or a "q" is entered
    if (!cin || s1 == "q") return false;
    cin >> s2;
    return true;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iterator>
using std::begin; using std::end;

#include <cstddef>
using std::size_t;

#include <iostream>
using std::cout; using std::endl;

// const int ia[] is equivalent to const int* ia
// size is passed explicitly and used to control access to elements of ia
void print(const int ia[], size_t size)
{
    for (size_t i = 0; i != size; ++i) {
        cout << ia[i] << endl;
    }
}

int main()
{
    int j[] = { 0, 1 };  // int array of size 2

    print(j, end(j) - begin(j));

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	do {
		cout << "Guess a number between 0 and 9" << endl;
		unsigned i, mynum = 7;
		cin >> i;

		if (i == mynum) {
			cout << "Congrats you guessed right!" << endl;
			break;
		} else
			if (i < mynum)
				cout << "too low" << endl;
			else
				cout << "too high" << endl;

		if (i != mynum)
			if (i < mynum)
				cout << "too low" << endl;
			else
				cout << "too high" << endl;
		else {
			cout << "Congrats you guessed right!" << endl;
			break;
		}
	} while (true);

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

// reference counted version of HasPtr
#include <string>

#include <cstddef>

class HasPtr {
public:
	// constructor allocates a new string and a new counter,
	// which it sets to 1
    HasPtr(const std::string &s = std::string()):
	  ps(new std::string(s)), i(0), use(new std::size_t(1)) {}

	// copy constructor copies all three data members
	// and increments the counter
    HasPtr(const HasPtr &p):
		ps(p.ps), i(p.i), use(p.use) { ++*use; }

	HasPtr& operator=(const HasPtr&);

	~HasPtr();

	// move constructor takes over the pointers from its argument
	// and makes the argument safe to delete
	HasPtr(HasPtr &&p): ps(p.ps), i(p.i), use(p.use)
		{ p.ps = 0; p.use = 0; }

	HasPtr &operator=(HasPtr&&);

private:
    std::string *ps;
    int    i;
	std::size_t *use;  // member to track how many objects share *ps
};

HasPtr::~HasPtr()
{
	if (--*use == 0) {   // if the reference count goes to 0
		delete ps;       // delete the string
		delete use;      // and the counter
	}
}

HasPtr &
HasPtr::operator=(HasPtr &&rhs)
{
	if (this != &rhs) {
		if (--*use == 0) {   // do the work of the destructor
			delete ps;
			delete use;
		}
		ps = rhs.ps;         // do the work of the move constructor
		i = rhs.i;
		use = rhs.use;
		ps = 0; use = 0;
	}
	return *this;
}

HasPtr& HasPtr::operator=(const HasPtr &rhs)
{
	++*rhs.use;  // increment the use count of the right-hand operand
	if (--*use == 0) {   // then decrement this object's counter
		delete ps;       // if no other users
		delete use;      // free this object's allocated members
	}
	ps = rhs.ps;         // copy data from rhs into this object
	i = rhs.i;
	use = rhs.use;
	return *this;        // return this object
}

HasPtr f(HasPtr hp) // HasPtr passed by value, so it is copied
{
	HasPtr ret;
	ret = hp;        // assignment copies the given HasPtr
	// proces ret
	return ret;      // ret and hp are destroyed
}

int main()
{
	HasPtr h("hi mom!");
	HasPtr h2 = h;  // no new memory is allocated,
	                // h and h2 share the same underlying string
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>

// value-like implementation of HasPtr
class HasPtr {
	friend void swap(HasPtr&, HasPtr&);
public:
    HasPtr(const std::string &s = std::string()):
		ps(new std::string(s)), i(0) { }

	// each HasPtr  has its own copy of the string to which ps points
    HasPtr(const HasPtr &p):
		ps(new std::string(*p.ps)), i(p.i) { }

	HasPtr& operator=(const HasPtr &);

	~HasPtr() { delete ps; }
private:
    std::string *ps;
    int    i;
};

inline
void swap(HasPtr &lhs, HasPtr &rhs)
{
	using std::swap;
	swap(lhs.ps, rhs.ps); // swap the pointers, not the string data
	swap(lhs.i, rhs.i);   // swap the int members
}

using std::string;
HasPtr& HasPtr::operator=(const HasPtr &rhs)
{
	auto newp = new string(*rhs.ps);  // copy the underlying string
	delete ps;       // free the old memory
	ps = newp;       // copy data from rhs into this object
	i = rhs.i;
	return *this;    // return this object
}

HasPtr f(HasPtr hp)  // HasPtr passed by value, so it is copied
{
	HasPtr ret = hp; // copies the given HasPtr
	// process ret
	return ret;      // ret and hp are destroyed
}

int main()
{
	HasPtr h("hi mom!");  // allocates a new copy of "hi mom!"
	f(h);  // copy constructor copies h in the call to f
		   // that copy is destroyed when f exits
}  // h is destroyed on exit, which destroys its allocated memory
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <string>
using std::string;

#include <cstddef>
using std::size_t;

int main()
{
	const string hexdigits = "0123456789ABCDEF";  // possible hex digits

	cout << "Enter a series of numbers between 0 and 15"
	     << " separated by spaces.  Hit ENTER when finished: "
	     << endl;
	string result;        // will hold the resulting hexify'd string

	string::size_type n;  // hold numbers from the input
	while (cin >> n)
		if (n < hexdigits.size())    // ignore invalid input
			result += hexdigits[n];  // fetch the indicated hex digit

	cout << "Your hex number is: " << result << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::endl; using std::cin; using std::cout;

#include <vector>
using std::vector;

#include <string>
using std::string;

const vector<string> scores = {"F", "D", "C", "B", "A", "A++"};
vector<unsigned> grades;

// these functions demonstrate alternative ways to handle the if tests
// function that takes an unsigned value and a string
// and returns a string
string goodVers(string lettergrade, unsigned grade)
{
	// add a plus for grades the end in 8 or 9 and a minus for those ending in 0, 1, or 2
	if (grade % 10 > 7)
		lettergrade += '+';	   // grades ending in 8 or 9 get a '+'
	else
		if (grade % 10 < 3)
			lettergrade += '-';   // those ending in 0, 1, or 2 get a '-'
	return lettergrade;
}

// incorrect version of the function to add a plus or minus to a grade
string badVers(string lettergrade, unsigned grade)
{
	// add a plus for grades the end in 8 or 9 and a minus for those ending in 0, 1, or 2
	// WRONG: execution does NOT match indentation; the else goes with the inner if
	if (grade % 10 >= 3)
		if (grade % 10 > 7)
			lettergrade += '+';  // grades ending in 8 or 9 get a +
	else
		lettergrade += '-'; // grades ending in 3, 4, 5, 6 will get a minus!
	return lettergrade;
}

// corrected version using the same logic path as badVers
string rightVers(string lettergrade, unsigned grade)
{
	// add a plus for grades that end in 8 or 9 and a minus for those ending in 0, 1, or 2
	if (grade % 10 >= 3) {
		if (grade % 10 > 7)
			lettergrade += '+';  // grades ending in 8 or 9 get a +
	} else                  // curlies force the else to go with the outer if
		lettergrade += '-'; // grades ending in 0, 1, or 2 will get a minus
	return lettergrade;
}

int main()
{
	// read a set of scores from the input
	unsigned grade;
	while (cin >> grade)
		grades.push_back(grade);

	// now process those grades
	for (auto it : grades) {   // for each grade we read
		cout << it << " " ;    // print the grade
		string lettergrade;    // hold coresponding letter grade
		// if failing grade, no need to check for a plus or minus
		if (it < 60)
			lettergrade = scores[0];
		else {
			lettergrade = scores[(it - 50)/10];  // fetch the letter grade
			if (it != 100)  // add plus or minus only if not already an A++
				if (it % 10 > 7)
					lettergrade += '+';   // grades ending in 8 or 9 get a +
				else if (it % 10 < 3)
					lettergrade += '-';   // grades ending in 0, 1, or 2 get a -
		}
		cout << lettergrade << endl;
		if (it > 59 && it !=100) {
			cout << "alternative versions: " << it << " ";
			// start over with just the basic grade, no + or -
			lettergrade = scores[(it - 50)/10];
			cout << goodVers(lettergrade, it) << " ";
			cout << badVers(lettergrade, it) << " ";
			cout << rightVers(lettergrade, it) << " ";
			cout << endl;
		}
	}

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

int main()
{
	int i = 0, j;
	j = ++i; // j = 1, i = 1: prefix yields the incremented value
	cout << i << " " << j << endl;

	j = i++; // j = 1, i = 2: postfix yields the unincremented value
	cout << i << " " << j << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>

namespace NS {
    class Quote {
	public:
		Quote() { std::cout << "Quote::Quote" << std::endl; }
	};
    void display(const Quote&)
		{ std::cout << "display(const Quote&)" << std::endl; }
}

// Bulk_item's base class is declared in namespace NS
class Bulk_item : public NS::Quote {
public:
	Bulk_item() { std::cout << "Bulk_item::Bulk_item" << std::endl; }
};

int main() {
    Bulk_item book1;

    display(book1); // calls Quote::display

    return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Sales_item.h"
#include <iostream>
#include <string>


int main() {

	int v1(1024);    // direct-initialization, functional form
	int v2{1024};    // direct-initialization, list initializer form
	int v3 = 1024;   // copy-initialization
	int v4 = {1024}; // copy-initialization, list initializer form


	// alternative ways to initialize string from a character string literal
	std::string titleA = "C++ Primer, 5th Ed.";
	std::string titleB("C++ Primer, 5th Ed.");
	std::string all_nines(10, '9');  // all_nines = "9999999999"

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

//inline version: find the shorter of two strings
inline const string &
shorterString(const string &s1, const string &s2)
{
        return s1.size() <= s2.size() ? s1 : s2;
}

int main()
{
	string s1("successes"), s2("failure");
	cout << shorterString(s1, s2) << endl;

	// call the size member of the string returned by shorterString
	cout << shorterString(s1, s2).size() << endl;

	// equivalent code as generated by the call to inline version
	// of shorterString
	cout << (s1.size() < s2.size() ? s1 : s2) << endl;
	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::copy;

#include <list>
using std::list;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include <iterator>
using std::inserter; using std::front_inserter;

void print(const string &label, const list<int> &lst)
{
	cout << label << endl;
	for (auto iter : lst)
        cout << iter << " ";
    cout << endl;
}

int main()
{

    list<int> lst = {1,2,3,4};
	print("lst", lst);

    // after copy completes, lst2 contains 4 3 2 1
	list<int> lst2, lst3;     // empty lists
    copy(lst.cbegin(), lst.cend(), front_inserter(lst2));

    // after copy completes, lst3 contains 1 2 3 4
    copy(lst.cbegin(), lst.cend(), inserter(lst3, lst3.begin()));

	print("lst2", lst2);
	print("lst3", lst3);

	vector<int> v = {1,2,3,4,5};
	list<int> new_lst = {6,7,8,9};
	auto it = new_lst.begin();
	copy(v.begin(), v.end(), inserter(new_lst, it));
	print("new_lst", new_lst);

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

int main()
{
	// ival1 is 3; result is truncated; remainder is discarded
	int ival1 = 21/6;

	// ival2 is 3; no remainder; result is an integral value
	int ival2 = 21/7;

	cout << ival1 << " " << ival2 << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::copy; using std::sort; using std::unique_copy;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <iterator>
using std::istream_iterator; using std::ostream_iterator;

#include <fstream>
using std::ofstream;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
    istream_iterator<int> int_it(cin); // reads ints from cin
    istream_iterator<int> int_eof;     // end iterator value
	vector<int> v(int_it, int_eof);    // initialize v by reading cin

    sort(v.begin(), v.end());
    ostream_iterator<int> out(cout, " "); // write ints to cout
    unique_copy(v.begin(), v.end(), out); // write unique elements to cout
    cout << endl;                         // write a newline after the output
	ofstream out_file("data/outFile2");   // writes int to named file
	ostream_iterator<int> out_iter(out_file, " ");
	copy(v.begin(), v.end(), out_iter);
	out_file << endl;  // write a newline at end of the file
    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
#include "Sales_item.h"

int main()
{
    Sales_item book;

    // read ISBN, number of copies sold, and sales price
    std::cin >> book;
    // write ISBN, number of copies sold, total revenue, and average price
    std::cout << book << std::endl;

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
#include <string>
#include <iostream>
using std::cout; using std::endl; using std::vector; using std::string;

// five functions illustrating different aspects of lambda expressions
void fcn1()
{
	size_t v1 = 42;  // local variable
	// copies v1 into the callable object named f
	auto f = [v1] { return v1; };
	v1 = 0;
	auto j = f(); // j is 42; f stored a copy of v1 when we created it
	cout << j << endl;
}

void fcn2()
{
	size_t v1 = 42;  // local variable
	// the object f2 contains a reference to v1
	auto f2 = [&v1] { return v1; };
	v1 = 0;
	auto j = f2(); // j is 0; f2 refers to v1; it doesn't store it
	cout << j << endl;
}

void fcn3()
{
	size_t v1 = 42;  // local variable
	// f can change the value of the variables it captures
	auto f = [v1] () mutable { return ++v1; };
	v1 = 0;
	auto j = f(); // j is 43
	cout << j << endl;
}

void fcn4()
{
	size_t v1 = 42;  // local variable
	// v1 is a reference to a nonconst variable
	// we can change that variable through the reference inside f2
	auto f2 = [&v1] { return ++v1; };
	v1 = 0;
	auto j = f2(); // j is 1
	cout << j << endl;
}

void fcn5()
{
    size_t v1 = 42;
	// p is a const pointer to v1
    size_t* const p = &v1;
	// increments v1, the objet to which p points
    auto f = [p]() { return ++*p; };
    auto j = f();  // returns incremented value of *p
    cout << v1 << " " << j << endl; // prints 43 43
    v1 = 0;
    j = f();       // returns incremented value of *p
    cout << v1 << " " << j << endl; // prints 1 1
}


int main()
{
	fcn1();
	fcn2();
	fcn3();
	fcn4();
	fcn5();
	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
int main()
{
	std::cout << "Hello World!";  // simple character string literal
	std::cout << "";              // empty character string literal
	// literal using newlines and tabs
	std::cout << "\nCC\toptions\tfile.[cC]\n";

    // multiline string literal
    std::cout << "a really, really long string literal "
	             "that spans two lines" << std::endl;

	// three ways to print a capital M
	std::cout << 'M' << " " << '\115' << " " << '\x4d' << std::endl;

    unsigned long long bigVal = -1ULL;
    std::cout << bigVal << std::endl;

    return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "LocalMath.h"

// return the greatest common divisor
int gcd(int v1, int v2)
{
    while (v2) {
        int temp = v2;
        v2 = v1 % v2;
        v1 = temp;
    }
    return v1;
}


// factorial of val is val * (val - 1) *  (val - 2) . . . * ((val -  (val - 1)) * 1)
int fact(int val)
{
	int ret = 1; // local variable to hold the result as we calculate it
	while (val > 1)
		ret *= val--;  // assign ret * val to ret and decrement val
	return ret;        // return the result
}

// recursive version of factorial:
// calculate val!, which is 1 * 2 * 3 . . . * val
int factorial(int val)
{
    if (val > 1)
        return factorial(val-1) * val;
    return 1;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "LocalMath.h"
#include <iostream>
using std::cout; using std::endl;

int main()
{
	// pass a literal to fact
    int f = fact(5);  // f equals 120, i.e., the result of fact(5)
	cout << "5! is " << f << endl;

    // call fact on i and print the result
	int i = 5;
    int j = fact(i);
	cout << i << "! is " << j << endl;

	// call fact on a const int
    const int ci = 3;
    int k = fact(ci);
	cout << ci << "! is " << k << endl;

    return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstdlib>
/* EXIT_FAILURE and EXIT_SUCCESS are preprocessor variables
 *       such variables are not in the std namespace,
 *       hence, no using declaration and no std:: when we use these names
*/
int main()
{
    bool some_failure = false;
    if (some_failure)
        return EXIT_FAILURE;  // defined in cstdlib
    else
        return EXIT_SUCCESS;  // defined in cstdlib
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

int main()
{
	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;
using std::boolalpha; using std::noboolalpha;
using std::oct; using std::dec; using std::hex;
using std::showbase; using std::noshowbase;
using std::uppercase; using std::nouppercase;

bool get_status()
{
	return false;
}

int main()
{
	bool b;
	cout << "default bool values: " << true << " " << false
	     << "\nalpha bool values: " << boolalpha
		 << true << " " << false << endl;

	bool bool_val = get_status();
	cout << boolalpha    // sets the internal state of cout
	     << bool_val
	     << noboolalpha; // resets the internal state to default formatting
	cout << endl;

	const int ival = 15, jval = 1024;  // const, so values never change

	cout << "default: " << 20 << " " << 1024 << endl;
	cout << "octal: " << oct << 20 << " " << 1024 << endl;
	cout << "hex: " << hex << 20 << " " << 1024 << endl;
	cout << "decimal: " << dec << 20 << " " << 1024 << endl;


	cout << showbase;    // show the base when printing integral values
	cout << "default: " << 20 << " " << 1024 << endl;
	cout << "in octal: " << oct  << 20 << " " << 1024 << endl;
	cout << "in hex: " << hex  << 20 << " " << 1024 << endl;
	cout << "in decimal: " << dec << 20 << " " << 1024 << endl;
	cout << noshowbase;  // reset the state of the stream

	cout << uppercase << showbase << hex
	     << "printed in hexadecimal: " << 20 << " " << 1024
	     << nouppercase << noshowbase << dec << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include "Version_test.h"
#ifdef HEX_MANIPS
using std::hexfloat; using std::defaultfloat;
#endif

int main()
{
	double pi = 3.14;
	cout << pi << " "
#ifdef HEX_MANIPS
	     << hexfloat << pi    // no workaround for this missing manipulator
#endif
	     << defaultfloat << " " << pi << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <set>
using std::multiset;

#include <map>
using std::map;

#include <string>
using std::string;

#include <utility>
using std::pair;

#include <iostream>
using std::cout; using std::endl;

#include "Sales_data.h"
#include "make_plural.h"

// SDComp points to a function that compares two Sales_data objects
typedef bool(*SDComp)(const Sales_data&, const Sales_data&);

// bookstore can have several transactions with the same ISBN
// elements in bookstore will be in ISBN order
multiset<Sales_data, decltype(compareIsbn)*>
	bookstore(compareIsbn);

// alternative way to declare bookstore using a lambda
multiset<Sales_data, SDComp>
	bookstore2([](const Sales_data &l, const Sales_data &r)
                 { return l.isbn() < r.isbn(); });

int main()
{
	map <string, size_t> word_count; // empty map

	// insert a value-initialized element with key Anna;
	// assign 1 to the value of that element
	word_count["Anna"] = 1;

	// fetch the element indexed by Anna; prints 1
	cout << word_count["Anna"] << endl;

	++word_count["Anna"];        // fetch the element and add 1 to it
	cout << word_count["Anna"] << endl; // prints 2

	// various ways to add word to word_count
	string word;
	word_count.insert({word, 1});
	word_count.insert(make_pair(word, 1));
	word_count.insert(pair<string, size_t>(word, 1));
	word_count.insert(map<string, size_t>::value_type(word, 1));

	typedef map<string,size_t>::value_type valType;
	word_count.insert(valType(word, 1));

	// use value returned by insert
	pair<map<string, size_t>::iterator, bool> insert_ret;

	// if Anna not already in word_count, insert it with value 1
	insert_ret = word_count.insert({"Anna", 1});

	if (insert_ret.second == false)    // Anna was already in the map
	    insert_ret.first->second++;    // increment current value
	cout << word_count["Anna"] << endl;

	// get an iterator to an element in word_count
	auto map_it = word_count.begin();

	// *map_it is a reference to a pair<const string, size_t> object
	cout << map_it->first;         // prints the key for this element
	cout << " " << map_it->second; // prints the value of the element
	++map_it->second;     // ok: we can change the value through an iterator
	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::endl;

#include <algorithm>
using std::find_if;

#include <functional>
using std::bind;
using std::placeholders::_1;

int main()
{
    vector<string> svec = {"hi", "bye"};
    // bind each string in the range to the implicit first argument to empty
    auto it = find_if(svec.begin(), svec.end(),
	                  bind(&string::empty, _1));
    if (it == svec.end())
		cout << "worked" << endl;
	else
		cout << "failed"  << endl;
	auto f =  bind(&string::empty, _1);
	f(*svec.begin()); // ok: argument is a string f will use .* to call empty
	f(&svec[0]); // ok: argument is a pointer to string f will use .-> to call empty
}


/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
#include <vector>
#include <iostream>

struct Base1 {
    void print(int) const     // public by default
		{ std::cout << "Base1::print(int) " << ival << std::endl; }
protected:
    int ival = 1;
};

struct Base2 {
    void print(double) const        // public by default
		{ std::cout << "Base2::print(double) " << ival << std::endl; }
protected:
    int ival = 2;
};

struct Derived : public Base1 {
    void print(std::string) const   // public by default
		{ std::cout << "Derived::print(string) " << ival << std::endl; }
protected:
	int ival = 3;
};

struct MI : public Derived, public Base2 {
    void print(std::vector<double>) // public by default
		{ std::cout << "MI::print(int(vector<double>) "
			        << ival << std::endl; }
protected:
    int ival = 4;
};

int main()
{
	MI obj;
	obj.Base1::print(0);
	obj.Base2::print(3.14);
	obj.Derived::print("hi");
	obj.print(std::vector<double>());

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include "make_plural.h"

int main()
{
	size_t cnt = 1;
	cout << make_plural(cnt, "success", "es") << endl;

	cnt = 2;
	cout << make_plural(cnt, "failure", "s") << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
#include <string>
#include <utility>
// for swap but we do not provide a using declaration for swap

// HasPtr with added move constructor
class HasPtr {
	friend void swap(HasPtr&, HasPtr&);
public:
	// default constructor and constructor that takes a string
    HasPtr(const std::string &s = std::string()):
		ps(new std::string(s)), i(0) { }

	// copy constructor
    HasPtr(const HasPtr &p):
		ps(new std::string(*p.ps)), i(p.i) { }

	// move constructor
	HasPtr(HasPtr &&p) noexcept : ps(p.ps), i(p.i) {p.ps = 0;}

	// assignment operator is both the move- and copy-assignment operator
	HasPtr& operator=(HasPtr rhs)
	               { swap(*this, rhs); return *this; }

	// destructor
	~HasPtr() { delete ps; }
private:
    std::string *ps;
    int    i;
};

inline
void swap(HasPtr &lhs, HasPtr &rhs)
{
	using std::swap;
	swap(lhs.ps, rhs.ps); // swap the pointers, not the string data
	swap(lhs.i, rhs.i);   // swap the int members
}

int main()
{
	HasPtr hp("hi mom");
	HasPtr hp2(hp);

	hp = hp2; // hp2 is an lvalue; copy constructor used to copy hp2
	hp = std::move(hp2); // move constructor moves hp2
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iterator>
using std::begin; using std::end;

#include <vector>
using std::vector;
#include <iostream>
using std::cout; using std::endl;

#include <cstddef>
using std::size_t;

int main()
{
	// array of size 3; each element is an array of 4 uninitailzed ints
	int ia1[3][4];

	// array of size 10; each element is a 20-element array
	// whose elements are arrays of 30 ints
	int arr[10][20][30] = {0}; // initialize all elements to 0

	// assigns the first element of arr to the last element
	// in the last row of ia
	ia1[2][3] = arr[0][0][0];

	// binds row to the second four-element array in ia
	int (&row)[4] = ia1[1];

	// three elements, each element is an array of size 4
	int ia2[3][4] = {
	    {0, 1, 2, 3},   // initializers for the row indexed by 0
	    {4, 5, 6, 7},   // initializers for the row indexed by 1
	    {8, 9, 10, 11}  // initializers for the row indexed by 2
	};

	// equivalent initialization without the optional
	// nested braces for each row
	int ia3[3][4] = {0,1,2,3,4,5,6,7,8,9,10,11};

	// explicitly initialize only element 0 in each row
	int ia4[3][4] = {{ 0 }, { 4 }, { 8 }};

	// explicitly initialize row 0; the remaining elements
	// are value initialized
	int ix[3][4] = {0, 3, 6, 9};

	// prints 9 0 0
	cout << ix[0][3] << ' ' << ix[1][0] << ' ' << ix[2][0] << endl;

	constexpr size_t rowCnt = 3, colCnt = 4;
	int ia[rowCnt][colCnt];   // 12 uninitialized elements

    // for each row
    for (size_t i = 0; i != rowCnt; ++i) {
        // for each column within the row
        for (size_t j = 0; j != colCnt; ++j) {
            // assign the element's positional index as its value
            ia[i][j] = i * colCnt + j;
		}
	}

	// four ways to print the contents of ia
	// 1. using nested range for loops
	for (const auto &row : ia) // for every element in the outer array
		for (auto col : row)   // for every element in the inner array
			cout << col << endl; // print the element's value
    cout << ia[0][0] << ' ' << ia[2][3] << endl; // prints 0 11


	// 2. using pointers and a traditional for loop
	//    with pointer arithmetic to calculate the end pointers
	for (auto p = ia; p != ia + rowCnt; ++p) {
		// q points to the first element of an array of four ints;
		// that is, q points to an int
	    for (auto q = *p; q != *p + colCnt; ++q)
	         cout << *q << ' ';
		cout << endl;
	}

	// 3. using pointers and a traditional for loop
	//    with the library begin and end functions to manage the pointers
	for (auto p = begin(ia); p != end(ia); ++p) {
		// q points to the first element in an inner array
		for (auto q = begin(*p); q != end(*p); ++q)
			cout << *q << ' ';  // prints the int value to which q points
		cout << endl;
	}

	// 4. using a type alias to declare the loop control variable
	using int_array = int[4]; // new style type alias declaration

	for (int_array *p = ia; p != ia + 3; ++p) {
	    for (int *q = *p; q != *p + 4; ++q)
	         cout << *q << ' ';
		cout << endl;
	}

	// alternative way to assign positional index to elements
	// in a two-dimensional array
	int alt_ia[rowCnt][colCnt]; // 12 uninitialized elements
	size_t cnt = 0;
	for (auto &row : alt_ia)    // for every element in the outer array
		for (auto &col : row) { // for every element in the inner array
			col = cnt;          // give this element the next value
			++cnt;              // increment cnt
		}
	// now print the value of the array
	for (const auto &row : alt_ia) // for every element in the outer array
		for (auto col : row)     // for every element in the inner array
			cout << col << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <map>
using std::multimap;

#include <string>
using std::string;

#include <utility>
using std::pair;

#include <iostream>
using std::cout; using std::endl;

int main()
{
    // map from author to title; there can be multiple titles per author
    multimap<string, string> authors;
    // add data to authors
    authors.insert({"Alain de Botton", "On Love"});
    authors.insert({"Alain de Botton", "Status Anxiety"});
    authors.insert({"Alain de Botton", "Art of Travel"});
    authors.insert({"Alain de Botton",
		                      "Architecture of Happiness"});

    string search_item("Alain de Botton"); // author we'll look for
    auto entries = authors.count(search_item); // number of elements
    auto iter = authors.find(search_item); // first entry for this author

    // loop through the number of entries there are for this author
    while(entries) {
		cout << iter->second << endl; // print each title
		++iter;     // advance to the next title
		--entries;  // keep track of how many we've printed
	}

    // definitions of authors and search_item as above
    // beg and end denote the range of elements for this author
    for (auto beg = authors.lower_bound(search_item),
              end = authors.upper_bound(search_item);
		 beg != end; ++beg)
        cout << beg->second << endl; // print each title

    // definitions of authors and search_item as above
    // pos holds iterators that denote the range of elements for this key
    for (auto pos = authors.equal_range(search_item);
         pos.first != pos.second; ++pos.first)
        cout << pos.first->second << endl; // print each title

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <string>
using std::string;

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <unordered_set>
using std::unordered_multiset;

#include <functional>

#include "Sales_data.h"

using std::hash;

int main()
{
	// uses hash<Sales_data> and Sales_data operator==
	unordered_multiset<Sales_data> SDset;
	Sales_data item;
	while (cin >> item) {
		SDset.insert(item);
	}
	cout << SDset.size() << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>

int main()
{
	int sum = 0, value = 0;

	// read until end-of-file, calculating a running total of all values read
	while (std::cin >> value)
		sum += value; // equivalent to sum = sum + value

	std::cout << "Sum is: " << sum << std::endl;
	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "make_plural.h"

#include <iostream>
using std::cin; using std::cerr; using std::cout; using std::endl;
using std::ostream;

#include <algorithm>
using std::for_each; using std::find_if; using std::stable_sort;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <fstream>
using std::ifstream;

#include <cstddef>
using std::size_t;

// comparison function to be used to sort by word length
bool isShorter(const string &s1, const string &s2)
{
    return s1.size() < s2.size();
}

// determine whether a length of a given word is 6 or more
bool GT(const string &s, string::size_type m)
{
    return s.size() >= m;
}

class SizeComp {
public:
	SizeComp() = delete;  // no default constructor
	SizeComp &operator=(const SizeComp&) = delete; // no assignment
	~SizeComp() = default;

	// constructor with a parameter for each captured variable
	SizeComp(size_t n): sz(n) { }

	// call operator with the same return type,
	// parameters, and body as the lambda
	bool operator()(const string &s) const { return s.size() >= sz; }
private:
	size_t sz;  // a data member for each variable captured by value
};

class PrintString {
public:
	PrintString() = delete;   // no default constructor
	PrintString(ostream &o) : os(o) { }
	void operator()(const string &s) const { os << s << " "; }
private:
	ostream &os;
};

class ShorterString {
public:
	bool operator()(const string &s1, const string &s2) const
	{ return s1.size() < s2.size(); }
};

void elimDups(vector<string> &words)
{
    // sort words alphabetically so we can find the duplicates
    sort(words.begin(), words.end());

	// print the sorted contents
	for_each(words.begin(), words.end(), PrintString(cerr));
	cerr << endl;

    // unique reorders the input so that each word appears once in the
    // front part of the range
	// returns an iterator one past the unique range;
    auto end_unique = unique(words.begin(), words.end());

    // erase uses a vector operation to remove the nonunique elements
    words.erase(end_unique, words.end());

	// print the reduced vector
	for_each(words.begin(), words.end(), PrintString(cerr));
	cerr << endl;
}

void biggies(vector<string> &words, vector<string>::size_type sz)
{
	elimDups(words);  // puts words in alphabetic order and removes duplicates

    // sort words by size using object of type ShorterString
	// maintaining alphabetic order for words of the same size
    stable_sort(words.begin(), words.end(), ShorterString());

	// use object of type SizeComp to find
	// the first element whose size() is >= sz
    auto wc = find_if(words.begin(), words.end(), SizeComp(sz));

	// compute the number of elements with size >= sz
	auto count = words.end() - wc;

	// print results
    cout << count << " " << make_plural(count, "word", "s")
         << " " << sz << " characters or longer" << endl;

	// use object of type PrintString
	// to print the contents of words, each one followed by a space
	for_each(wc, words.end(), PrintString(cout));
	cout << endl;
}

int main()
{
    vector<string> words;

    // copy contents of each book into a single vector
    string next_word;
    while (cin >> next_word) {
        // insert next book's contents at end of words
        words.push_back(next_word);
    }

	biggies(words, 6);

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::find_if; using std::for_each;
using std::sort; using std::stable_sort;
using std::unique;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <fstream>
using std::ifstream;

#include <cstddef>
using std::size_t;

#include <functional>
using std::bind;
using std::placeholders::_1;
using namespace std::placeholders;

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include "make_plural.h"

// comparison function to be used to sort by word length
bool isShorter(const string &s1, const string &s2)
{
    return s1.size() < s2.size();
}

// determine whether a length of a given word is 6 or more
bool GT(const string &s, string::size_type m)
{
    return s.size() >= m;
}

void elimDups(vector<string> &words)
{
    // sort words alphabetically so we can find the duplicates
    sort(words.begin(), words.end());
	for_each(words.begin(), words.end(),
	         [](const string &s) { cout << s << " "; });
	cout << endl;


    // unique reorders the input so that each word appears once in the
    // front part of the range
	// returns an iterator one past the unique range
    auto end_unique = unique(words.begin(), words.end());
	for_each(words.begin(), words.end(),
	         [](const string &s) { cout << s << " "; });
	cout << endl;

    // erase uses a vector operation to remove the nonunique elements
    words.erase(end_unique, words.end());
	for_each(words.begin(), words.end(),
	         [](const string &s) { cout << s << " "; });
	cout << endl;
}

void
biggies(vector<string> &words, vector<string>::size_type sz)
{
	elimDups(words); // put words in alphabetical order and remove duplicates
    // sort words by size, but maintain alphabetical order for words of the same size
    stable_sort(words.begin(), words.end(),
	            [](const string &a, const string &b)
	              { return a.size() < b.size();});

	// get an iterator to the first element whose size() is >= sz
    auto wc = find_if(words.begin(), words.end(),
                [sz](const string &a)
	                { return a.size() >= sz; });

	// compute the number of elements with size >= sz
	auto count = words.end() - wc;
    cout << count << " " << make_plural(count, "word", "s")
         << " of length " << sz << " or longer" << endl;

	// print words of the given size or longer, each one followed by a space
	for_each(wc, words.end(),
	         [](const string &s){cout << s << " ";});
	cout << endl;
}

bool check_size(const string &s, string::size_type sz)
{
	return s.size() >= sz;
}

int main()
{
    vector<string> words;

    // copy contents of each book into a single vector
    string next_word;
    while (cin >> next_word) {
        // insert next book's contents at end of words
        words.push_back(next_word);
    }

	biggies(words, 5); // biggies changes its first argument

	// alternative solution using bind and check_size function
	// NB: words was changed inside biggies,
	//     at this point in the program words has only unique
	//     words and is in order by size
	size_t sz = 5;
	auto
	wc = find_if(words.begin(), words.end(),
	             bind(check_size, std::placeholders::_1, sz));
	auto count = words.end() - wc;
    cout << count << " " << make_plural(count, "word", "s")
         << " of length " << sz << " or longer" << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout;
using std::noskipws; using std::skipws;

int main()
{
	char ch;
	cin >> noskipws;  // set cin so that it reads whitespace
	while (cin >> ch)
		cout << ch;
	cin >> skipws;    // reset cin to the default state
	                  // so that it ignores whitespace

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <ctime>
using std::time;

#include <cstdlib>
using std::rand;

#include <random>
using std::default_random_engine;
using std::normal_distribution;

#include <iostream>
using std::cerr; using std::cout; using std::endl;

#include <vector>
using std::vector;

#include <algorithm>
using std::max_element;

#include <numeric>
using std::accumulate;

#include <cmath>
using std::lround;

#include <cstddef>
using std::size_t;

int main()
{
	default_random_engine e;        // generates random integers
	normal_distribution<> n(4,1.5); // mean 4, standard deviation 1.5
	vector<unsigned> vals(9);       // nine elements each 0

	for (size_t i = 0; i != 200; ++i) {
		unsigned v = lround(n(e));  // round to the nearest integer
		if (v < vals.size())        // if this result is in range
			++vals[v];              // count how often each number appears
	}

	int sum = accumulate(vals.begin(), vals.end(), 0);

	if (sum != 200)
		cout << "discarded " << 200 - sum << " results" << endl;

	for (size_t j = 0; j != vals.size(); ++j)
		cout << j << ": " << string(vals[j], '*') << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>

int main()
{
	// currVal is the number we're counting; we'll read new values into val
	int currVal = 0, val = 0;

	// read first number and ensure that we have data to process
	if (std::cin >> currVal) {
		int cnt = 1;  // store the count for the current value we're processing
		while (std::cin >> val) { // read the remaining numbers
			if (val == currVal)   // if the values are the same
				++cnt;            // add 1 to cnt
			else { // otherwise, print the count for the previous value
				std::cout << currVal << " occurs "
				          << cnt << " times" << std::endl;
				currVal = val;    // remember the new value
				cnt = 1;          // reset the counter
			}
		}  // while loop ends here
		// remember to print the count for the last value in the file
		std::cout << currVal << " occurs "
		          << cnt << " times" << std::endl;
	} // outermost if statement ends here
	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include <cstddef>
using std::size_t;

#include <new>
using std::nothrow;

size_t get_size() { return 42; }

int main()
{
	// if allocation fails, new returns a null pointer
	int *p1 = new int; // if allocation fails, new throws std::bad_alloc
	int *p2 = new (nothrow) int; // if allocation fails, new returns a null pointer

	int i0;                  // named, uninitialized int variable

	int *p0 = new int;       // pi points to a dynamically allocated,
	                         // unnamed, uninitialized int
	delete p0;  // frees the memory to which pi points

	// named initialized variables
	int i(1024);             // value of i is 1024
	string s(10, '9');       // value of s is "9999999999"
	vector<int> v = {0,1,2,3,4,5,6,7,8,9};

	// unnamed, initialized dynamically allocated objects
	int *pi = new int(1024); // object to which pi points has value 1024
	string *ps = new string(10, '9');   // *ps is "9999999999"
	// vector with ten elements with values from 0 to 9
	vector<int> *pv = new vector<int>{0,1,2,3,4,5,6,7,8,9};

	cout << "*pi: " << *pi
	     << "\ti: " << i << endl
	     << "*ps: " << *ps
	     << "\ts: " << s << endl;

	for (auto b = pv->begin(); b != pv->end(); ++b)
		cout << *b << " ";
	cout << endl;

	// when we're done using the memory must delete the pointers
	delete pi;  // frees the memory to which pi points
	delete ps;  // frees the string to which ps points
	            // the string destructor frees the space used by its data
	delete pv;  // frees the memory for the vector
	            // which also destroys the elements in that vector

	// call get_size to determine how many ints to allocate
	int *pia = new int[get_size()]; // pia points to the first of these ints
	delete [] pia; // brackets used to delete pointer to element in an array
	typedef int arrT[42];  // arrT names the type array of 42 ints
	int *p = new arrT;     // allocates an array of 42 ints; p points to the first one
	delete [] p;           // brackets are necessary because we allocated an array

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

#include <cctype>
using std::toupper;

// chapter 6 will explain functions
// tolower and toupper change the argument itself, not a local copy
string &tolower(string &s)
{
	for (auto &i : s)
		i = tolower(i);
	return s;
}

string &toupper(string &s)
{
	for (auto &i : s)
		i = toupper(i);
	return s;
}

int main()
{
	int i = 0;
	cout << i << " " << ++i << endl;  // undefined

	string s("a string"), orig = s;
	cout << toupper(s) << endl;  // changes s to  uppercase
	cout << tolower(s) << endl;  // changes s to lowercase

	s = orig;
	// the calls to toupper and tolower change the value of s
	// << doesn't guarantee order of evaluation,
	// so this expression is undefined
	cout << toupper(s) << " " << tolower(s) << endl;

	string first = toupper(s);  // we control the order of evaluation
	string second = tolower(s); // by storing the results in the order in which we want

	cout << first << " " << second << endl;  // one possible evaluation
	cout << second << " " << first << endl;  // equally legal evaluation!
	cout << first << " " << first << endl;   // another legal evaluation!
	cout << second << " " << second << endl; // and a fourth!

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iterator>
using std::istream_iterator; using std::ostream_iterator;

#include<vector>
using std::vector;

#include<iostream>
using std::cin; using std::cout; using std::endl;

int main() {
	vector<int> vec;
	istream_iterator<int> in_iter(cin);  // read ints from cin
	istream_iterator<int> eof;           // istream ``end'' iterator

	while (in_iter != eof)
		vec.push_back(*in_iter++);
	ostream_iterator<int> out_iter(cout, " ");

	for (auto e : vec)
		out_iter = e;  // the assignment writes this element to cout
	cout << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
    char ch;
    // initialize counters for each vowel
    unsigned vowelCnt = 0;
    unsigned otherCnt = 0;  // count anything that isn't a vowel

    while (cin >> ch) {
        // if ch is a vowel, increment the appropriate counter
        switch (ch) {
			case 'a': case 'e': case 'i': case 'o': case 'u':
				++vowelCnt;
				break;
            default:
                ++otherCnt;
                break;
        }
    }
    // print results
    cout << "Number of vowels: \t" << vowelCnt << '\n'
         << "Total non-vowels : \t" << otherCnt << '\n';

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>

namespace libs_R_us {
    extern void print(int)
		{ std::cout << "libs_R_us::print(int)" << std::endl; }
    extern void print(double)
		{ std::cout << "libs_R_us::print(double)" << std::endl; }
}

// ordinary declaration
void print(const std::string &)
{
	std::cout << "print(const std::string &)" << std::endl;
}

// this using directive adds names to the candidate set for calls to print:
using namespace libs_R_us;

// the candidates for calls to print at this point in the program are:
//     print(int) from libs_R_us
//     print(double) from libs_R_us
//     print(const std::string &) declared explicitly

int main()
{
	int ival = 42;
    print("Value: "); // calls global print(const string &)
    print(ival);      // calls libs_R_us::print(int)

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>

namespace AW {
    int print(int i)
		{ std::cout << "AW::print(int)" << std::endl; return i; }
}
namespace Primer {
    double print(double d)
		{ std::cout << "Primer::print(double)" << std::endl; return d; }
}

// using directives create an overload set of functions from different namespaces
using namespace AW;
using namespace Primer;

long double print(long double);

int main() {
    print(1);   // calls AW::print(int)
    print(3.1); // calls Primer::print(double)

    return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

int main()
{
	short short_value = 32767; // max value if shorts are 16 bits

	short_value += 1; // this calculation overflows
	cout << "short_value: " << short_value << endl;

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstring>
using std::strcmp;

#include <iostream>
using std::cout; using std::endl;

// first version; can compare any two types
template <typename T> int compare(const T&, const T&);

// second version to handle string literals
template<size_t N, size_t M>
int compare(const char (&)[N], const char (&)[M]);

// specialized verson of the first template, handles character arrays
template <>
int compare(const char* const &, const char* const &);

template <typename T> int compare(const T& v1, const T& v2)
{
cout << "base template" << endl;
    if (v1 < v2) return -1;
    if (v2 < v1) return 1;
    return 0;
}

template<size_t N, size_t M>
int compare(const char (&p1)[N], const char (&p2)[M])
{
cout << "array template" << endl;
	return strcmp(p1, p2);
}


// special version of compare to handle pointers to character arrays
template <>
int compare(const char* const &p1, const char* const &p2)
{
cout << "specialized template" << endl;
    return strcmp(p1, p2);
}

int main()
{
	const char *p1 = "hi", *p2 = "mom";
	compare(p1, p2);      // calls the first template
	compare("hi", "mom"); // calls the template with two nontype parameters
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <list>
using std::list;

#include <vector>
using std::vector;

#include <algorithm>
using std::sort;

#include <iterator>
using std::istream_iterator; using std::ostream_iterator;

#include <utility>
using std::pair; using std::make_pair;

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include "Sales_data.h"

pair<string, string> anon;       // holds two strings
pair<string, size_t> word_count; // holds a string and an size_t
pair<string, vector<int>> line;  // holds string and vector<int>

// list initialize the members in a pair
pair<string, string> author{"James", "Joyce"};

// ways to initialize a pair
typedef pair<string, string> Author;
Author proust("Marcel", "Proust");  // construct a pair
Author joyce{"James", "Joyce"};     // list initialize a pair
Author austen = make_pair("Jane", "Austen"); // use make_pair

void preliminaries(vector<string> &v)
{
	// process v
	istream_iterator<string> input(cin), eof;
	copy(input, eof, back_inserter(v));
	sort(v.begin(), v.end(),
	     [](const string &a, const string &b)
	     { return a.size() < b.size(); });
}

// three different ways to return a pair
// 1. list initialize the return value
pair<string, int>
process(vector<string> &v)
{
	if (!v.empty())
		return {v.back(), v.back().size()}; // list initialize
	else
		return pair<string, int>(); // explicitly constructed return value
}

// 2. use make_pair to generate the return value
pair<string, int>
process2(vector<string> &v)
{
	// process v
	if (!v.empty())
		return make_pair(v.back(), v.back().size());
	else
		return pair<string, int>();
}

// 3. explicitly construct the return value
pair<string, int>
process3(vector<string> &v)
{
	// process v
	if (!v.empty())
		return pair<string, int>(v.back(), v.back().size());
	else
		return pair<string, int>();
}

int main()
{
	vector<string> v;
	string s;
	while (cin >> s)
		v.push_back(s);

	preliminaries(v);  // sort v into size order

	// all three output statements should be the same
	auto biggest = process(v);
	cout << biggest.first << " " << biggest.second << endl;
	biggest = process2(v);
	cout << biggest.first << " " << biggest.second << endl;
	biggest = process3(v);
	cout << biggest.first << " " << biggest.second << endl;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Version_test.h"

// if the regular expression library isn't support, do nothing
#ifdef REGEX

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <string>
using std::string;

#include <regex>
using std::regex; using std::sregex_iterator; using std::smatch;

void checkPattern(const regex &r, const string &s)
{
	smatch results;
	if (regex_search(s, results, r))
		cout << results.str() << endl;
	else
		cout << "no match for " << s << endl;
}

int main()
{
	// phone has 10 digits, optional parentheses around the area code
	// components are separated by an optional space, ',' or '-'
	string pattern = "\\(?\\d{3}\\)?[-. ]?\\d{3}[-. ]?\\d{4}";
	regex r(pattern);  // a regex to match our pattern

	// some numbers to try to match
	string mtch1 = "(908) 555-0181";
	string mtch2 = "(908)555-0182";
	string mtch3 = "908 555-0183";
	string mtch4 = "908.555-0184";
	string mtch5 = "9085550185";

	smatch results;
	checkPattern(r, mtch1);
	checkPattern(r, mtch2);
	checkPattern(r, mtch3);
	checkPattern(r, mtch4);
	checkPattern(r, mtch5);

	string s;
	while (getline(cin, s))
	{
		checkPattern(r, s);
	}

	return 0;
}

#else

// do nothing
int main() { return 0; }

#endif

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Version_test.h"

// if the regular expression library isn't support, do nothing
#ifdef REGEX

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <string>
using std::string;

#include <regex>
using std::regex; using std::sregex_iterator; using std::smatch;
using std::regex_error;
using std::regex_constants::format_no_copy;

int main()
{
	// phone has 10 digits, optional parentheses around the area code
	// components are separated by an optional space, ',' or '-'
	string phone = "\\(?\\d{3}\\)?[-. ]?\\d{3}[-. ]?\\d{4}";

	// parentheses indicate subexpressions;
	// our overall expression has 7 subexpressions:
	//     ( ddd ) space ddd - dddd
	// the subexpressions 1, 3, 4, and 6 are optional
	// the subexpressions 2, 5, and 7 hold the digits of the number
	phone = "(\\()?(\\d{3})(\\))?([-. ])?(\\d{3})([-. ])?(\\d{4})";
	regex r(phone);  // a regex to find our pattern
	smatch m;        // a match object for the results
	string s;

	// generate just the phone numbers:  use a new format string
	string fmt = "$2.$5.$7"; // reformat numbers to ddd.ddd.dddd
	string fmt2 = "$2.$5.$7 "; // adds space at the end as a separator

	// read each record from the input file
	while (getline(cin, s))
	{
		cout << regex_replace(s, r, fmt) << endl;

		// tell regex_replace to copy only the text that it replaces
		cout << regex_replace(s, r, fmt2, format_no_copy) << endl;
	}

	return 0;
}
#else

// do nothing
int main() { return 0; }

#endif

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;
using std::showpoint; using std::noshowpoint;

int main()
{
	cout << 10.0 << endl;         // prints 10
	cout << showpoint << 10.0     // prints 10.0000
	     << noshowpoint << endl;  // revert to default format

	cout << 10.0 << endl;  // prints 10

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <iomanip>
using std::setprecision;

#include <cmath>
using std::sqrt;

int main()
{
	// cout.precision reports the current precision value
	cout  << "Precision: " << cout.precision()
	      << ", Value: "   << sqrt(2.0) << endl;

	// cout.precision(12) asks that 12 digits of precision be printed
	cout.precision(12);
	cout << "Precision: " << cout.precision()
	     << ", Value: "   << sqrt(2.0) << endl;

	// alternative way to set precision using the setprecision manipulator
	cout << setprecision(3);
	cout << "Precision: " << cout.precision()
	     << ", Value: "   << sqrt(2.0) << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

int main()
{
	cout << 6 + 3 * 4 / 2 + 2 << endl;

	// parentheses in this expression match default precedence and associativity
	cout << ((6 + ((3 * 4) / 2)) + 2) << endl; // prints 14

	int temp = 3 * 4;         // 12
	int temp2 = temp / 2;     // 6
	int temp3 = temp2 + 6;    // 12
	int result = temp3 + 2;   // 14
	cout << result << endl;

	// parentheses result in alternative groupings
	cout << (6 + 3) * (4 / 2 + 2) << endl;     // prints 36
	cout << ((6 + 3) * 4) / 2 + 2 << endl;     // prints 20
	cout << 6 + 3 * 4 / (2 + 2) << endl;       // prints 9

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iterator>
using std::begin; using std::end;

#include <cstddef>
using std::size_t;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	int ia[] = {0,1,2,3,4,5,6,7,8,9};

	int *p = ia; // p points to the first element in ia
	++p;           // p points to ia[1]

	int *e = &ia[10]; // pointer just past the last element in ia
	for (int *b = ia; b != e; ++b)
		cout << *b << " "; // print the elements in ia
	cout << endl;

	const size_t sz = 10;
	int arr[sz];  // array of 10 ints

	for (auto &n : arr) // for each element in arr
		cin >> n;  // read values from the standard input

	for (auto i : arr)
		cout << i << " ";
	cout << endl;

	// pbeg points to the first and
	// pend points just past the last element in arr
	int *pbeg = begin(arr),  *pend = end(arr);

	// find the first negative element,
	// stopping if we've seen all the elements
	while (pbeg != pend && *pbeg >= 0)
		++pbeg;
	if (pbeg == pend)
		cout << "no negative elements in arr" << endl;
	else
		cout << "first negative number was " << *pbeg << endl;
	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "compare.h"
#include "Blob.h"

#include <string>
using std::string;

// Application.cc
// these template types must be instantiated elsewhere in the program
// instantion declaration and definition
extern template class Blob<string>;
extern template int compare(const int&, const int&);

int main() {

	Blob<string> sa1, sa2; // instantiation will appear elsewhere

	// Blob<int> and its initializer_list constructor
	// are instantiated in this file
	Blob<int> a1 = {0,1,2,3,4,5,6,7,8,9};
	Blob<int> a2(a1);  // copy constructor instantiated in this file

	int i = compare(a1[0], a2[0]); // instantiation will appear elsewhere

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Query.h"
#include "TextQuery.h"

#include <memory>
using std::shared_ptr; using std::make_shared;

#include <set>
using std::set;

#include <algorithm>
using std::set_intersection;

#include <iostream>
using std::ostream;

#include <cstddef>
using std::size_t;

#include <iterator>
using std::inserter;

// returns the lines not in its operand's result set
QueryResult
NotQuery::eval(const TextQuery& text) const
{
    // virtual call to eval through the Query operand
    auto result = query.eval(text);

	// start out with an empty result set
    auto ret_lines = make_shared<set<line_no>>();

	// we have to iterate through the lines on which our operand appears
	auto beg = result.begin(), end = result.end();

    // for each line in the input file, if that line is not in result,
    // add that line number to ret_lines
	auto sz = result.get_file()->size();
    for (size_t n = 0; n != sz; ++n) {
		// if we haven't processed all the lines in result
		// check whether this line is present
		if (beg == end || *beg != n)
			ret_lines->insert(n);  // if not in result, add this line
		else if (beg != end)
			++beg; // otherwise get the next line number in result if there is one
	}
	return QueryResult(rep(), ret_lines, result.get_file());
}

// returns the intersection of its operands' result sets
QueryResult
AndQuery::eval(const TextQuery& text) const
{
    // virtual calls through the Query operands to get result sets for the operands
    auto left = lhs.eval(text), right = rhs.eval(text);

	// set to hold the intersection of left and right
    auto ret_lines = make_shared<set<line_no>>();

    // writes the intersection of two ranges to a destination iterator
    // destination iterator in this call adds elements to ret
    set_intersection(left.begin(), left.end(),
                   right.begin(), right.end(),
                   inserter(*ret_lines, ret_lines->begin()));
    return QueryResult(rep(), ret_lines, left.get_file());
}

// returns the union of its operands' result sets
QueryResult
OrQuery::eval(const TextQuery& text) const
{
    // virtual calls through the Query members, lhs and rhs
	// the calls to eval return the QueryResult for each operand
    auto right = rhs.eval(text), left = lhs.eval(text);

	// copy the line numbers from the left-hand operand into the result set
	auto ret_lines =
	     make_shared<set<line_no>>(left.begin(), left.end());

	// insert lines from the right-hand operand
	ret_lines->insert(right.begin(), right.end());
	// return the new QueryResult representing the union of lhs and rhs
    return QueryResult(rep(), ret_lines, left.get_file());
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <fstream>
using std::ifstream;

#include <iostream>
using std::cin; using std::cout; using std::cerr;
using std::endl;

#include <cstdlib>  // for EXIT_FAILURE

#include "TextQuery.h"
#include "make_plural.h"

void runQueries(ifstream &infile)
{
	// infile is an ifstream that is the file we want to query
    TextQuery tq(infile);  // store the file and build the query map
    // iterate with the user: prompt for a word to find and print results
    while (true) {
        cout << "enter word to look for, or q to quit: ";
        string s;
        // stop if we hit end-of-file on the input or if a 'q' is entered
        if (!(cin >> s) || s == "q") break;
		// run the query and print the results
        print(cout, tq.query(s)) << endl;
    }
}

// program takes single argument specifying the file to query
int main(int argc, char **argv)
{
    // open the file from which user will query words
    ifstream infile;
	// open returns void, so we use the comma operator XREF(commaOp)
	// to check the state of infile after the open
    if (argc < 2 || !(infile.open(argv[1]), infile)) {
        cerr << "No input file!" << endl;
        return EXIT_FAILURE;
    }
	runQueries(infile);
    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Quote.h"

#include <algorithm>
using std::min;

#include <cstddef>
using std::size_t;

#include <iostream>
using std::ostream; using std::endl;
using std::cout;

// calculate and print the price for the given number of copies, applying any discounts
double print_total(ostream &os,
                   const Quote &item, size_t n)
{
	// depending on the type of the object bound to the item parameter
	// calls either Quote::net_price or Bulk_quote::net_price
	double ret = item.net_price(n);
    os << "ISBN: " << item.isbn() // calls Quote::isbn
       << " # sold: " << n << " total due: " << ret << endl;
 	return ret;
}

// if the specified number of items are purchased, use the discounted price
double Bulk_quote::net_price(size_t cnt) const
{
    if (cnt >= quantity)
        return cnt * (1 - discount) * price;
    else
        return cnt * price;
}

// use discounted price for up to a specified number of items
// additional items priced at normal, undiscounted price
double Lim_quote::net_price(size_t cnt) const
{
    size_t discounted = min(cnt, quantity);
    size_t undiscounted = cnt - discounted;
    return discounted * (1 - discount) * price
           + undiscounted * price;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <ctime>
using std::time;

#include <cstdlib>
using std::rand;

#include <random>
using std::default_random_engine;
using std::uniform_int_distribution;
using std::normal_distribution;

#include <iostream>
using std::cerr; using std::cout; using std::endl;

#include <vector>
using std::vector;

#include <algorithm>
using std::max_element;

#include <cstddef>
using std::size_t;

int main()
{
	default_random_engine e;  // generates random unsigned integers
	for (size_t i = 0; i < 10; ++i)
		// e() "calls" the object to produce the next random number
		cout << e() << " ";
	cout << endl;

	// uniformly distributed from 0 to 9 inclusive
	uniform_int_distribution<unsigned> u(0,9);
	default_random_engine e2;
	for (size_t i = 0; i < 10; ++i)
		// u uses e as a source of numbers
		// each call returns a uniformly distributed value
		// in the specified range
    	cout << u(e2) << " ";
	cout << endl;

	default_random_engine e3;
	// generates normally distributed doubles
	// with mean 100, standard deviation 15
	normal_distribution<> n(100,15);
	for (size_t i = 0; i < 10; ++i)
    	cout << n(e3) << " ";
	cout << endl;

	// bad, but common way to generate random numbers in a given range
	for (size_t i = 0; i < 10; ++i)
		// r will be a between 0 and 9, but randomness is compromised
		cout << rand()%10 << " ";
	cout << endl;

	default_random_engine e4;
	// uniformly distributed from 0 to 9 inclusive
	uniform_int_distribution<unsigned> u2(0,9);
	for (size_t i = 0; i < 10; ++i)
    	cout << u2(e4) << " ";
	cout << endl;

	// seeding the engine causes it to generate different numbers
	// on different executions
	default_random_engine e5(time(0));
	for (size_t i = 0; i < 10; ++i)
    	cout << u2(e5) << " ";
	cout << endl;

    // assuming shorts have 16 bits
    uniform_int_distribution<short> us1;     // values from 0 to 32767
    uniform_int_distribution<short> us2(42); // values from 42 to 32767
    cout << "min: " << us1.min() << " max: " << us1.max() << endl;
    cout << "min: " << us2.min() << " max: " << us2.max() << endl;

    default_random_engine e6;
    cout << "min: " << e6.min() << " max: " << e6.max() << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <ctime>
using std::time;

#include <cstdlib>
using std::rand;

#include <random>
using std::default_random_engine;
using std::uniform_int_distribution;
using std::normal_distribution;

#include <iostream>
using std::cerr; using std::cout; using std::endl;

#include <vector>
using std::vector;

#include <cstddef>
using std::size_t;

#include <algorithm>
using std::max_element;

#include <numeric>
using std::accumulate;

#include <cmath>
using std::lround;

int main()
{
	vector<int> vals(32);     // preallocate so each element is 0
	default_random_engine e;  // generates numbers
	uniform_int_distribution<unsigned> u(0,31); // inclusive range
	for (size_t i = 0; i != 100; ++i)
		++vals[u(e)];         // count how often each number appears
	int m = *max_element(vals.begin(), vals.end());
	for (int i = m; i != 0; --i) {
		for (size_t j = 0; j != vals.size(); ++j)
			if (vals[j] > i-1) cout << "* ";
			else               cout << "  ";
		cout << endl;
	}

	vector<int> vals2(32);     // preallocate so each element 0 value
	default_random_engine e2;  // restart the sequence
	normal_distribution<> n(15,5); // mean 15, standard deviation 5
	for (size_t i = 0; i != 100; ++i) {
		size_t v = lround(n(e));
		if (v < vals.size())
			++vals[v];         // count how often each number appears
		else
			cout << "discarding: " << v << " ";
	}
	cout << endl;

	cout << std::accumulate(vals.begin(), vals.end(), 0) << endl;
	m = *max_element(vals.begin(), vals.end());
	for (int i = m; i != 0; --i) {
		for (size_t j = 0; j != vals.size(); ++j)
			if (vals[j] > i-1) cout << "* ";
			else               cout << "  ";
		cout << endl;
	}

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <ctime>
using std::time;

#include <cstdlib>
using std::rand;

#include <random>
using std::default_random_engine;
using std::uniform_int_distribution;
using std::uniform_real_distribution;

#include <iostream>
using std::cerr; using std::cout; using std::endl;

#include <vector>
using std::vector;

#include <cstddef>
using std::size_t;

#include <algorithm>
using std::max_element;

int main()
{
	default_random_engine e;  // generates unsigned random integers
	// uniformly distributed from 0 to 1 inclusive
	uniform_real_distribution<double> u(0,1);
	for (size_t i = 0; i < 10; ++i)
    	cout << u(e) << " ";
	cout << endl;

	// empty <> signify we want to use the default result type
	uniform_real_distribution<> u2(0,1); // generates double by default
	default_random_engine e2;
	for (size_t i = 0; i < 10; ++i)
    	cout << u2(e2) << " ";  // should generate the same sequence
	cout << endl;

	default_random_engine e3;
	// uniformly distributed from 0 to 9 inclusive
	uniform_int_distribution<unsigned> u3(0,9);
	for (size_t i = 0; i < 100; ++i)
    	cout << u3(e3) << ((i != 99)? " ": "");
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <ctime>
using std::time;

#include <cstdlib>
using std::rand;

#include <random>
using std::default_random_engine;
using std::uniform_int_distribution;

#include <iostream>
using std::cerr; using std::cout; using std::endl;

#include <vector>
using std::vector;

// almost surely the wrong way to generate a vector of random integers
// output from this function will be the same 100 numbers on every call!
vector<unsigned> bad_randVec()
{
	default_random_engine e;
	uniform_int_distribution<unsigned> u(0,9);
	vector<unsigned> ret;
	for (size_t i = 0; i < 100; ++i)
    	ret.push_back(u(e));
	return ret;
}

// returns a vector of 100 uniformly distributed random numbers
vector<unsigned> good_randVec()
{
	// because engines and distributions retain state, they usually should be
	// defined as static so that new numbers are generated on each call
	static default_random_engine e;
	static uniform_int_distribution<unsigned> u(0,9);
	vector<unsigned> ret;
	for (size_t i = 0; i < 100; ++i)
    	ret.push_back(u(e));
	return ret;
}

int main()
{
	vector<unsigned> v1(bad_randVec());
	vector<unsigned> v2(bad_randVec());

	// will print equal
	cout << ((v1 == v2) ? "equal" : "not equal") << endl;

	// very unlikely to print equal
	if (good_randVec() == good_randVec())
		cout << "equal!" << endl;
	else
		cout << "not equal" << endl;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <vector>
using std::vector;

#include <string>
using std::string;

int main()
{
	vector<int> ivec;
	vector<int> v = {0,1,2,3,4,5,6,7,8,9};

	// range variable must be a reference so we can write to the elements
	for (auto &r : v)   // for each element in v
		r *= 2;         // double the value of each element in v

	// print every element in v
	for (int r : v)
		cout << r << " "; // print the elements in v
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <algorithm>
using std::find;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	string line;
	getline(cin, line);

	// find the first element in a comma-separated list
	auto comma = find(line.cbegin(), line.cend(), ',');
	cout << string(line.cbegin(), comma) << endl;

	// find the last element in a comma-separated list
	auto rcomma = find(line.crbegin(), line.crend(), ',');

	// WRONG: will generate the word in reverse order
	cout << string(line.crbegin(), rcomma) << endl;

	// ok: get a forward iterator and read to the end of line
	cout << string(rcomma.base(), line.cend()) << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::for_each;

#include <iostream>
using std::cin; using std::cout; using std::endl; using std::cerr;
using std::istream; using std::ostream;

#include <string>
using std::string;

#include <vector>
using std::vector;

class PrintString {
public:
    PrintString(ostream &o = cout, char c = ' '):
		os(o), sep(c) { }
    void operator()(const string &s) const { os << s << sep; }
private:
    ostream &os;   // stream on which to write
	char sep;      // character to print after each output
};

class ReadLine {
public:
	ReadLine() = delete;
	ReadLine(istream &i) : is(i) { }
	bool operator()(string &s) const { return getline(is, s); }
private:
	istream &is;
};

int main()
{
	vector<string> vs;
	ReadLine rl(cin);    // object that read lines from cin
	string s;
	while (rl(s))        // store what rl reads into s
		vs.push_back(s);

	cout << "read : " << vs.size() << " elements" << endl;
	PrintString printer;   // uses the defaults; prints to cout
	printer(s);            // prints s followed by a space on cout

	PrintString errors(cerr, '\n');
	errors(s);             // prints s followed by a newline on cerr

	cerr << "for_each printing to cerr" << endl;
	for_each(vs.begin(), vs.end(), PrintString(cerr, '\n'));
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Version_test.h"

// if the regular expression library isn't support, do nothing
#ifdef REGEX

#include <iostream>
using std::cout; using std::endl;

#include <regex>
using std::regex; using std::sregex_iterator; using std::smatch;
using std::regex_error;

int main()
{
	try {
		// missing close bracket after alnum; the constructor will throw
		regex r("[[:alnum:]+\\.(cpp|cxx|cc)$", regex::icase);
	} catch (regex_error e)
	     { cout << e.what() << "\ncode: " << e.code() << endl; }

	return 0;
}
#else

// do nothing
int main() { return 0; }

#endif

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
int main()
{
	int i = 0, &ri = i;  // ri is a reference to i
	// ri is just another name for i;
	// this statement prints the value of i twice
	std::cout << i << " " << ri << std::endl;

	i = 5; // changing i is reflected through ri as well
	std::cout << i << " " << ri << std::endl;

	ri = 10; // assigning to ri actually assigns to i
	std::cout << i << " " << ri << std::endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

char &get_val(string &str, string::size_type ix)
{
    return str[ix]; // get_val assumes the given index is valid
}

int main()
{
    string s("a value");
    cout << s << endl;   // prints a value

    get_val(s, 0) = 'A'; // changes s[0] to A
    cout << s << endl;   // prints A value

    return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <string>
using std::string;

#include <vector>
using std::vector;

#include <cstddef>
using std::size_t;

// returns the index of the first occurrence of c in s
// the reference parameter occurs counts how often c occurs
string::size_type find_char(const string &s, char c,
                           string::size_type &occurs)
{
    auto ret = s.size();   // position of the first occurrence, if any
    occurs = 0;            // set the occurrence count parameter

    for (decltype(ret) i = 0; i != s.size(); ++i) {
        if (s[i] == c) {
            if (ret == s.size())
                ret = i;   // remember the first occurrence of c
            ++occurs;      // increment the occurrence count
         }
	}
    return ret;            // count is returned implicitly in occurs
}

// returns an iterator that refers to the first occurrence of value
// the reference parameter occurs contains a second return value
vector<int>::const_iterator find_val(
    vector<int>::const_iterator beg,  // first element
    vector<int>::const_iterator end,  // one past last element
    int value,                        // the value we want
    vector<int>::size_type &occurs)   // number of times it occurs
{
    auto res_iter = end; // res_iter will hold first occurrence, if any
    occurs = 0;          // set occurrence count parameter

    for ( ; beg != end; ++beg)
        if (*beg == value) {
            // remember first occurrence of value
            if (res_iter == end)
                res_iter = beg;
            ++occurs;    // increment occurrence count
         }

    return res_iter;     // count returned implicitly in occurs
}

int main()
{

	string s;
	getline(cin, s);
	size_t ctr = 0;
	auto index = find_char(s, 'o', ctr);
	cout << index << " " << ctr << endl;

	vector<int> ivec;
	int i;
	// read values into ivec
	while (cin >> i)
		ivec.push_back(i);

	// for each value in the list of ints
	for (auto i : {42, 33, 92}) {
		auto it = find_val(ivec.begin(), ivec.end(), i, ctr);
		if (it == ivec.end())
			cout << i << " is not in the input data" << endl;
		else
			cout << i << " was at position "
			     << it - ivec.begin() << endl;
	}

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::endl;

void printVec(const vector<int> &vi)
{
	// print the vector's elements
	auto iter = vi.begin();
	while (iter != vi.end())
		cout << *iter++ << endl;
}

int main()
{
	// silly loop to remove even-valued elements
	// and insert a duplicate of odd-valued elements
	vector<int> vi = {0,1,2,3,4,5,6,7,8,9};
	printVec(vi);

	// we call begin, not cbegin because we're changing vi
	auto iter = vi.begin();
	while (iter != vi.end()) {
		if (*iter % 2) {    // if the element is odd
			iter = vi.insert(iter, *iter);  // duplicate  it
			iter += 2; // advance past this element and the new one
		} else
			iter = vi.erase(iter);          // remove even elements
			// don't advance the iterator;
			// iter denotes the element after the one we erased
	}
	printVec(vi);

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

// get returns a reference to an element in the given array
int &get(int *arry, int index) { return arry[index]; }

int main() {
    int ia[10];  // array of ten uninitialized ints

    for (int i = 0; i != 10; ++i)
        get(ia, i) = i;  // call get to assign values to the elements

	for (auto i : ia)    // print the elements
		cout << i << " ";
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Version_test.h"

// if the regular expression library isn't support, do nothing
#ifdef REGEX

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

#include <regex>
using std::regex; using std::sregex_iterator; using std::smatch;

int main()
{
	// find the characters ei that follow a character other than c
	string pattern("[^c]ei");
	// we want the whole word in which our pattern appears
	pattern = "[[:alpha:]]*" + pattern + "[[:alpha:]]*";

	regex r(pattern); // construct a regex to find pattern
	smatch results;   // define an object to hold the results of a search

	// define a string that has text that does and doesn't match pattern
	string test_str = "receipt freind theif receive";

	// use r to find a match to pattern in test_str
	if (regex_search(test_str, results, r)) // if there is a match
		cout << results.str() << endl;      // print the matching word

	sregex_iterator it(test_str.begin(), test_str.end(), r);
	sregex_iterator end_it;   // end iterator
	for ( ; it != end_it; ++it)
		cout << it->str() << endl;     // print current match

	// alternative way to obtain all the matches in a given string
	auto it2 = test_str.cbegin();
	while (it2 != test_str.cend() &&
	       regex_search(it2, test_str.cend(), results, r)) {
		cout << results.str() << endl;
		// reposition the iterator past any nonmatched part
		// of the string plus the size of this match
		it2 += results.prefix().length() + results.length();

	}

	return 0;
}
#else

// do nothing
int main() { return 0; }

#endif

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <memory>
using std::unique_ptr;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	unique_ptr<string> p1(new string("Stegosaurus"));

	// transfers ownership from p1
	// (which points to the string Stegosaurus) to p2
	unique_ptr<string> p2(p1.release()); // release makes p1 null
	cout << *p2 << endl; // prints Stegosaurus

	unique_ptr<string> p3(new string("Trex"));

	// reset deletes the memory to which p2 had pointed
	// and transfers ownership from p3 to p2
	p2.reset(p3.release());
	cout << *p2 << endl; // prints Trex

	// p1 is null, p2 is steg, and p3 is trex
	if (p1)
		cout << "p1 not null?" << endl;
	if (p3)
		cout << "p2 not null?" << endl;
	cout << *p2 << endl;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <vector>
using std::vector;

// function that takes a reference to an int
// and sets the given object to zero
// i is just another name for the object passed to reset
void reset(int &i)
{
    i = 0;  // changes the value of the object to which i refers
}

// function that takes a pointer
// and sets the pointed-to value to zero
void reset(int *ip)
{
    *ip = 0;  // changes the value of the object to which ip points
    ip = 0;   // changes the local copy of ip; the argument is unchanged
}

int main()
{
	int j = 42;
	reset(j);  // j is passed by reference; the value in j is changed
	cout << "j = " << j  << endl;  // prints j = 0

	j = 42;    // restore the original value of j
	reset(&j);                     // changes j but not the address of j
	cout << "j = "  << j << endl;  // prints j = 0

	j = 42;    // restore the original value of j
	int *p = &j;
	reset(p); // changes object to which p points not the address in p
	cout << "j = "  << *p << endl;  // prints j = 0

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <map>
using std::map;

#include <set>
using std::set;

#include <string>
using std::string;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
    // count the number of times each word occurs in the input
    map<string, size_t> word_count; // empty map from string to size_t
	set<string> exclude = {"The", "But", "And", "Or", "An", "A",
	                       "the", "but", "and", "or", "an", "a"};
    string word;
    while (cin >> word)
		// count only words that are not in exclude
		if (exclude.find(word) == exclude.end())
			++word_count[word];   // fetch and increment the counter for word

	for (const auto &w : word_count) // for each element in the map
		// print the results
		cout <<  w.first << " occurs " << w.second
		     << ((w.second > 1) ? " times" : " time") << endl;

return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include<iostream>
using std::cout; using std::endl;

int main()
{
    vector<int> vec = {0,1,2,3,4,5,6,7,8,9};
    // reverse iterator of vector from back to front
    for (auto r_iter = vec.crbegin(); // binds r_iter to the last element
              r_iter != vec.crend();  // one before first element
              ++r_iter)          // decrements the iterator one element
        cout << *r_iter << endl; // prints 9, 8, 7, . . . 0
    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::copy; using std::sort;

#include <iterator>
using std::istream_iterator; using std::ostream_iterator;

#include <vector>
using std::vector;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	vector<int> vec;
	istream_iterator<int> in(cin), eof;
	copy (in, eof, back_inserter(vec));

	sort(vec.begin(), vec.end()); // sorts vec in ``normal'' order
	vector<int> vec2(vec);        // vec2 is a copy of vec

	// sorts in reverse: puts the smallest element at the end of vec
	sort(vec.rbegin(), vec.rend());

	// prints vec
	ostream_iterator<int> out(cout, " ");
	copy(vec.begin(), vec.end(), out);    // reverse sort
	cout << endl;

	// prints vec2
	copy(vec2.begin(), vec2.end(), out);  // forward sort
	cout << endl;

	// it refers to the first element in vec
	auto it = vec.begin();

	// rev_it refers one before the first element in vec
	vector<int>::reverse_iterator rev_it(it);
	cout << *(rev_it.base()) << endl; // prints first element in vec

	// ways to print value at beginning of vec through it and rev_it
	cout << *it << endl;
	cout << *(rev_it.base()) << endl;
	cout << *(rev_it - 1) << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::find; using std::find_if; using std::for_each;
using std::remove_copy_if; using std::reverse_copy;
using std::reverse;

#include <iterator>
using std::back_inserter;

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	vector<int> v1 = {0,1,2,3,4,5,6,7,8,9};
	vector<int> v2;
	vector<int> v3 = v1;

	find(v1.begin(), v1.end(), 42);  // find first element equal to 42
	find_if(v1.begin(), v1.end(),    // find first odd element
	        [](int i) { return i % 2; });

	// puts elements in v1 into reverse order
	reverse(v1.begin(), v1.end());
	v1 = v3;  // restore original data

	// copies elements from v1 into v2 in reverse order; v1 is unchanged
	reverse_copy(v1.begin(), v1.end(), back_inserter(v2));

	for (auto i : v1)
		cout << i << " ";   // prints 0 1 2 . . . 8 9
	cout << endl;
	for (auto i : v2)
		cout << i << " ";   // prints 9 8 7 . . . 1 0
	cout << endl;

	// removes the odd elements from v1
	auto it = remove_if(v1.begin(), v1.end(),
	                    [](int i) { return i % 2; });
	// prints 0 2 4 6 8
	for_each(v1.begin(), it, [](int i) { cout << i << " "; });
	cout << endl;

	v1 = v3;    // restore original data
	v2.clear(); // make v2 empty again

	// copies only the even elements from v1 into v2; v1 is unchanged
	remove_copy_if(v1.begin(), v1.end(), back_inserter(v2),
	               [](int i) { return i % 2; });
	for (auto i : v2)
		cout << i << " ";  // prints 0 2 4 6 8
	cout << endl;
	for (auto i : v1)      // prints 0 1 2 . . . 8 9
		cout << i << " ";
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/


#include <iostream>
using std::istream; using std::ostream;

#include "Sales_data.h"
Sales_data::Sales_data(std::istream &is)
{
	// read will read a transaction from is into this object
	read(is, *this);
}

double
Sales_data::avg_price() const {
	if (units_sold)
		return revenue/units_sold;
	else
		return 0;
}

// add the value of the given Sales_data into this object
Sales_data&
Sales_data::combine(const Sales_data &rhs)
{
	units_sold += rhs.units_sold; // add the members of rhs into
	revenue += rhs.revenue;       // the members of ``this'' object
	return *this; // return the object on which the function was called
}

Sales_data
add(const Sales_data &lhs, const Sales_data &rhs)
{
	Sales_data sum = lhs;  // copy data members from lhs into sum
	sum.combine(rhs);      // add data members from rhs into sum
	return sum;
}

// transactions contain ISBN, number of copies sold, and sales price
istream&
read(istream &is, Sales_data &item)
{
	double price = 0;
	is >> item.bookNo >> item.units_sold >> price;
	item.revenue = price * item.units_sold;
	return is;
}

ostream&
print(ostream &os, const Sales_data &item)
{
	os << item.isbn() << " " << item.units_sold << " "
	   << item.revenue << " " << item.avg_price();
	return os;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Sales_data.h"
#include <string>
using std::istream; using std::ostream;

Sales_data::Sales_data(istream &is)
{
	is >> *this; // read a transaction from is into this object
}

double Sales_data::avg_price() const
{
	if (units_sold)
		return revenue/units_sold;
	else
		return 0;
}

// member binary operator: left-hand operand is bound to the implicit this pointer
// assumes that both objects refer to the same book
Sales_data& Sales_data::operator+=(const Sales_data &rhs)
{
	units_sold += rhs.units_sold;
	revenue += rhs.revenue;
	return *this;
}

// assumes that both objects refer to the same book
Sales_data
operator+(const Sales_data &lhs, const Sales_data &rhs)
{
	Sales_data sum = lhs;  // copy data members from lhs into sum
	sum += rhs;            // add rhs into sum
	return sum;
}

istream &operator>>(istream &is, Sales_data &item)
{
	double price;  // no need to initialize; we'll read into price before we use it
	is >> item.bookNo >> item.units_sold >> price;
	if (is)        // check that the inputs succeeded
    	item.revenue = item.units_sold * price;
	else
    	item = Sales_data(); // input failed: give the object the default state
	return is;
}

ostream &operator<<(ostream &os, const Sales_data &item)
{
	os << item.isbn() << " " << item.units_sold << " "
	   << item.revenue << " " << item.avg_price();
	return os;
}

// operators replace these original named functions
istream &read(istream &is, Sales_data &item)
{
	double price = 0;
	is >> item.bookNo >> item.units_sold >> price;
	item.revenue = price * item.units_sold;
	return is;
}
ostream &print(ostream &os, const Sales_data &item)
{
	os << item.isbn() << " " << item.units_sold << " "
	   << item.revenue << " " << item.avg_price();
	return os;
}

Sales_data add(const Sales_data &lhs, const Sales_data &rhs)
{
	Sales_data sum = lhs;  // copy data members from lhs into sum
	sum += rhs;            // add rhs into sum
	return sum;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::istream; using std::ostream;

#include "Sales_data.h"

// define the hash interface for Sales_data

namespace std {
size_t
hash<Sales_data>::operator()(const Sales_data& s) const
{
    return hash<string>()(s.bookNo) ^
           hash<unsigned>()(s.units_sold) ^
           hash<double>()(s.revenue);
}
}  // close the std namespace; note: no semicolon after the close curly

// remaining members unchanged from chapter 14
Sales_data::Sales_data(istream &is)
{
	is >> *this; // read a transaction from is into this object
}

double Sales_data::avg_price() const
{
	if (units_sold)
		return revenue/units_sold;
	else
		return 0;
}

// member binary operator: left-hand operand is bound to the implicit this pointer
// assumes that both objects refer to the same book
Sales_data& Sales_data::operator+=(const Sales_data &rhs)
{
	units_sold += rhs.units_sold;
	revenue += rhs.revenue;
	return *this;
}

// assumes that both objects refer to the same book
Sales_data
operator+(const Sales_data &lhs, const Sales_data &rhs)
{
	Sales_data sum = lhs;  // copy data members from lhs into sum
	sum += rhs;            // add rhs into sum
	return sum;
}

istream &operator>>(istream &is, Sales_data &item)
{
	double price;  // no need to initialize; we'll read into price before we use it
	is >> item.bookNo >> item.units_sold >> price;
	if (is)        // check that the inputs succeeded
    	item.revenue = item.units_sold * price;
	else
    	item = Sales_data(); // input failed: give the object the default state
	return is;
}

ostream &operator<<(ostream &os, const Sales_data &item)
{
	os << item.isbn() << " " << item.units_sold << " "
	   << item.revenue << " " << item.avg_price();
	return os;
}

// operators replace these original named functions
istream &read(istream &is, Sales_data &item)
{
	double price = 0;
	is >> item.bookNo >> item.units_sold >> price;
	item.revenue = price * item.units_sold;
	return is;
}
ostream &print(ostream &os, const Sales_data &item)
{
	os << item.isbn() << " " << item.units_sold << " "
	   << item.revenue << " " << item.avg_price();
	return os;
}

Sales_data add(const Sales_data &lhs, const Sales_data &rhs)
{
	Sales_data sum = lhs;  // copy data members from lhs into sum
	sum += rhs;            // add rhs into sum
	return sum;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::istream; using std::ostream;

#include "Sales_data.h"
#include "bookexcept.h"

// this version of the compound assignment operator
// throws an exception if the objects refer to different books
Sales_data& Sales_data::operator+=(const Sales_data &rhs)
{
    if (isbn() != rhs.isbn())
        throw isbn_mismatch("wrong isbns", isbn(), rhs.isbn());
    units_sold += rhs.units_sold;
    revenue += rhs.revenue;
    return *this;
}

// operator+ code is unchanged, but because it uses +=
// this version of the function also throws when called
// for books whose isbns differ
Sales_data
operator+(const Sales_data &lhs, const Sales_data &rhs)
{
	Sales_data sum = lhs;  // copy data members from lhs into sum
	sum += rhs;            // add rhs into sum
	return sum;
}

// remaning functions unchanged from chapter 16
// define the hash interface for Sales_data
namespace std {
size_t
hash<Sales_data>::operator()(const Sales_data& s) const
{
    return hash<string>()(s.bookNo) ^
           hash<unsigned>()(s.units_sold) ^
           hash<double>()(s.revenue);
}
}  // close the std namespace; note: no semicolon after the close curly

// remaining members unchanged from chapter 14
Sales_data::Sales_data(istream &is)
{
	is >> *this; // read a transaction from is into this object
}

double Sales_data::avg_price() const
{
	if (units_sold)
		return revenue/units_sold;
	else
		return 0;
}

istream &operator>>(istream &is, Sales_data &item)
{
	double price;  // no need to initialize; we'll read into price before we use it
	is >> item.bookNo >> item.units_sold >> price;
	if (is)        // check that the inputs succeeded
    	item.revenue = item.units_sold * price;
	else
    	item = Sales_data(); // input failed: give the object the default state
	return is;
}

ostream &operator<<(ostream &os, const Sales_data &item)
{
	os << item.isbn() << " " << item.units_sold << " "
	   << item.revenue << " " << item.avg_price();
	return os;
}

// operators replace these original named functions
istream &read(istream &is, Sales_data &item)
{
	double price = 0;
	is >> item.bookNo >> item.units_sold >> price;
	item.revenue = price * item.units_sold;
	return is;
}
ostream &print(ostream &os, const Sales_data &item)
{
	os << item.isbn() << " " << item.units_sold << " "
	   << item.revenue << " " << item.avg_price();
	return os;
}

Sales_data add(const Sales_data &lhs, const Sales_data &rhs)
{
	Sales_data sum = lhs;  // copy data members from lhs into sum
	sum += rhs;            // add rhs into sum
	return sum;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
#include <string>
#include "Sales_data.h"

int main()
{
	Sales_data data1, data2;

	// code to read into data1 and data2
	double price = 0;  // price per book, used to calculate total revenue

	// read the first transactions: ISBN, number of books sold, price per book
	std::cin >> data1.bookNo >> data1.units_sold >> price;
	// calculate total revenue from price and units_sold
	data1.revenue = data1.units_sold * price;

	// read the second transaction
	std::cin >> data2.bookNo >> data2.units_sold >> price;
	data2.revenue = data2.units_sold * price;

	// code to check whether data1 and data2 have the same ISBN
	//        and if so print the sum of data1 and data2
	if (data1.bookNo == data2.bookNo) {
		unsigned totalCnt = data1.units_sold + data2.units_sold;
		double totalRevenue = data1.revenue + data2.revenue;

		// print: ISBN, total sold, total revenue, average price per book
		std::cout << data1.bookNo << " " << totalCnt
		          << " " << totalRevenue << " ";
		if (totalCnt != 0)
			std::cout << totalRevenue/totalCnt << std::endl;
		else
			std::cout  << "(no sales)" << std::endl;

		return 0;  // indicate success
	} else {  // transactions weren't for the same ISBN
		std::cerr << "Data must refer to the same ISBN"
		          << std::endl;
		return -1; // indicate failure
	}
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
#include <cstddef>
using std::size_t;

using std::cout;
using std::endl;
#include "Quote.h"

int main()
{
	Quote basic("0-201-54848-8", 45);
	Bulk_quote bulk("0-201-82470-1", 45, 3, .15);

	// basic has type Quote; bulk has type Bulk_quote
	print_total(cout, basic, 20); // calls Quote version of net_price
	print_total(cout, bulk, 20);  // calls Bulk_quote version of net_price
	Quote base("0-201-82470-1", 50);
	Bulk_quote derived("0-201-82470-1", 50, 5, .19);
	cout << derived.net_price(20); // calls Bulk_quote::net_price
	cout << endl;

	base = derived;        // copies the Quote part of derived into base
	cout << base.net_price(20);    // calls Quote::net_price
	cout << endl;

	Quote &item = derived; // dynamic and static types of item differ
	cout << item.net_price(20);    // calls Bulk_quote::net_price

	item.isbn();           // isbn is not virtual, calls Bulk::isbn
	cout << endl;

	return 0;
}


/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cmath>
using std::sqrt;

#include <iostream>
using std::cout; using std::endl;
using std::fixed; using std::scientific;
using std::uppercase; using std::nouppercase;

#include "Version_test.h"
#ifdef HEX_MANIPS
using std::hexfloat; using std::defaultfloat;
#endif

int main()
{
	cout << "default format: " << 100 * sqrt(2.0) << '\n'
		 << "scientific: " << scientific << 100 * sqrt(2.0) << '\n'
	     << "fixed decimal: " << fixed << 100 * sqrt(2.0) << '\n'
#ifdef HEX_MANIPS     // no workaround for this missing manipulator
		 << "hexadecimal: " << hexfloat << 100 * sqrt(2.0) << '\n'
#endif
		 << "use defaults: " << defaultfloat << 100 * sqrt(2.0)
		 << "\n\n";

	cout << uppercase
	     << "scientific: " << scientific << sqrt(2.0) << '\n'
	     << "fixed decimal: " << fixed << sqrt(2.0) << '\n'
#ifdef HEX_MANIPS     // no workaround for this missing manipulator
		 << "hexadecimal: " << hexfloat << sqrt(2.0) << "\n\n"
#endif
		 << nouppercase;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

struct Base {
    Base(): mem(0) { }
protected:
    int mem;
};

struct Derived : Base {
    Derived(int i): mem(i) { } // initializes Derived::mem to i
	                           // Base::mem is default initialized
    int get_mem() { return mem; }  // returns Derived::mem
    int get_base_mem() { return Base::mem; }
	// . . .
protected:
    int mem;   // hides mem in the base
};

int main()
{
    Derived d(42);
    cout << d.get_mem() << endl;       // prints 42
    cout << d.get_base_mem() << endl;  // prints 0
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>

// Program for illustration purposes only: It is bad style for a function
// to use a global variable and also define a local variable with the same name

int reused = 42;  // reused has global scope

int main()
{
	int unique = 0; // unique has block scope

	// output #1: uses global reused; prints 42 0
	std::cout << reused << " " << unique << std::endl;

	int reused = 0; // new, local object named reused hides global reused

	// output #2: uses local reused; prints 0 0
	std::cout << reused << " " <<  unique << std::endl;

	// output #3: explicitly requests the global reused; prints 42 0
	std::cout << ::reused << " " <<  unique << std::endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced. Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Screen.h"

Screen::Action Screen::Menu[] = { &Screen::home,
                                  &Screen::forward,
                                  &Screen::back,
                                  &Screen::up,
                                  &Screen::down,
                                };

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <ctime>
using std::time;

#include <cstdlib>
using std::rand;

#include <random>
using std::default_random_engine;
using std::uniform_int_distribution;

#include <iostream>
using std::cerr; using std::cout; using std::endl;

#include <vector>
using std::vector;

int main()
{
	default_random_engine e1;             // uses the default seed
	default_random_engine e2(2147483646); // use the given seed value

	// e3 and e4 will generate the same sequence
	// because they use the same seed
	default_random_engine e3;        // uses the default seed value
	e3.seed(32767);                  // call seed to set a new seed value
	default_random_engine e4(32767); // set the seed value to 32767
	for (size_t i = 0; i != 100; ++i) {
		if (e1() == e2())
			cout << "unseeded match at iteration: " << i << endl;
		if (e3() != e4())
			cout << "seeded differs at iteration: " << i << endl;
	}

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cerr; using std::endl;

#include <fstream>
using std::fstream;

#include <string>
using std::string;

#include <cstdlib> // for EXIT_FAILURE

int main()
{
    // open for input and output and preposition file pointers to end-of-file
	// file mode argument
    fstream inOut("data/copyOut",
                   fstream::ate | fstream::in | fstream::out);
    if (!inOut) {
        cerr << "Unable to open file!" << endl;
        return EXIT_FAILURE; // EXIT_FAILURE
    }

    // inOut is opened in ate mode, so it starts out positioned at the end
    auto end_mark = inOut.tellg();// remember original end-of-file position
    inOut.seekg(0, fstream::beg); // reposition to the start of the file
    size_t cnt = 0;               // accumulator for the byte count
    string line;                  // hold each line of input

    // while we haven't hit an error and are still reading the original data
    while (inOut && inOut.tellg() != end_mark
           && getline(inOut, line)) { // and can get another line of input
        cnt += line.size() + 1;       // add 1 to account for the newline
		auto mark = inOut.tellg();    // remember the read position
        inOut.seekp(0, fstream::end); // set the write marker to the end
        inOut << cnt;                 // write the accumulated length
        // print a separator if this is not the last line
        if (mark != end_mark) inOut << " ";
        inOut.seekg(mark);            // restore the read position
    }
    inOut.seekp(0, fstream::end);     // seek to the end
    inOut << "\n";                    // write a newline at end-of-file

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <cstddef>
using std::size_t;

struct numbered {
	static size_t sn;
	numbered() : mysn(sn++) { }
	numbered(const numbered &) : mysn(sn++) { }
	numbered &operator=(const numbered &) { return *this; }
	size_t mysn;
};

size_t numbered::sn = 0;

void f (numbered s) { cout << s.mysn << endl; }

int main()
{
	numbered a, b = a, c = b;
	f(a); f(b); f(c);
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <set>
using std::set; using std::multiset;

#include <string>
using std::string;

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	// define a vector with 20 elements,
	// holding two copies of each number from 0 to 9
	vector<int> ivec;
	for (vector<int>::size_type i = 0; i != 10; ++i) {
	    ivec.push_back(i);
	    ivec.push_back(i);  // duplicate copies of each number
	}

	// iset holds unique elements from ivec; miset holds all 20 elements
	set<int> iset(ivec.cbegin(), ivec.cend());
	multiset<int> miset(ivec.cbegin(), ivec.cend());

	cout << ivec.size() << endl;    // prints 20
	cout << iset.size() << endl;    // prints 10
	cout << miset.size() << endl;   // prints 20

	// returns an iterator that refers to the element with key == 1
	iset.find(1);
	iset.find(11);  // returns the iterator == iset.end()
	iset.count(1);  // returns 1
	iset.count(11); // returns 0

	// returns an iterator to the first element with key == 1
	iset.find(1);
	iset.find(11);   // returns the iterator == iset.end()
	miset.count(1);  // returns 2
	miset.count(11); // returns 0

	set<string> set1;    // empty set
	set1.insert("the");  // set1 now has one element
	set1.insert("and");  // set1 now has two elements

	ivec = {2,4,6,8,2,4,6,8}; // ivec now has eight elements
	set<int> set2;            // empty set
	set2.insert(ivec.cbegin(), ivec.cend()); // set2 has four elements
	set2.insert({1,3,5,7,1,3,5,7});      // set2 now has eight elements

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;
using std::left; using std::right; using std::internal;

#include <iomanip>
using std::setw; using std::setfill;

int main()
{
	int i = -16;
	double d = 3.14159;

	// pad the first column to use a minimum of 12 positions in the output
	cout << "i: " << setw(12) << i << "next col" << '\n'
	     << "d: " << setw(12) << d << "next col" << '\n';

	// pad the first column and left-justify all columns
	cout << left
	     << "i: " << setw(12) << i << "next col" << '\n'
	     << "d: " << setw(12) << d << "next col" << '\n'
	     << right;           // restore normal justification

	// pad the first column and right-justify all columns
	cout << right
	     << "i: " << setw(12) << i << "next col" << '\n'
	     << "d: " << setw(12) << d << "next col" << '\n';

	// pad the first column but put the padding internal to the field
	cout << internal
	     << "i: " << setw(12) << i << "next col" << '\n'
	     << "d: " << setw(12) << d << "next col" << '\n';

	// pad the first column, using # as the pad character
	cout << setfill('#')
	     << "i: " << setw(12) << i << "next col" << '\n'
	     << "d: " << setw(12) << d << "next col" << '\n'
	     << setfill(' ');   // restore the normal pad character

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

int main()
{
	int grade = 75;
	cout << ((grade < 60) ?  "fail" : "pass"); // prints pass or fail
	cout << endl;

	cout << (grade < 60) ?  "fail" : "pass";   // prints 1 or 0!
	cout << endl;

	// previous expression is equivalent to the following
	cout << (grade < 60);    // prints 1 or 0
	cout ?  "fail" : "pass"; // test cout and then yield one of the two literals
	                         // depending on whether cout is true or false
	cout << endl;
	int i = 15, j = 20;
	cout << (i < j ? i : j);  // ok: prints smaller of i and j
	cout << endl;

	cout << (i < j) ? i : j;  // ok: prints 1 or 0!
	cout << endl;

	// previous expression is equivalent to the following
	cout << (i < j); // prints 1 or 0
	cout ? i : j;    // test cout and then evaluate i or j
	                 // depending on whether cout evaluates to true or false
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include "Sales_data.h"

int main()
{
	Sales_data data, *p;
	sizeof(Sales_data); // size required to hold an object of type Sales_data
	sizeof data; // size of data's type, i.e., sizeof(Sales_data)
	sizeof p;    // size of a pointer
	sizeof *p;   // size of the type to which p points, i.e., sizeof(Sales_data)
	sizeof data.revenue; // size of the type of Sales_data's revenue member
	sizeof Sales_data::revenue; // alternative way to get the size of revenue

	cout << "short: " << sizeof(short) << "\n"
	     << "short[3]: " << sizeof(short[3]) << "\n"
	     << "short*: " << sizeof(short*) << "\n"
	     << "short&: " << sizeof(short&) << endl;

	cout << endl;

	cout << "int: " << sizeof(int) << "\n"
	     << "int[3]: " << sizeof(int[3]) << "\n"
	     << "int*: " << sizeof(int*) << "\n"
	     << "int&: " << sizeof(int&) << endl;

	cout << endl;

	cout << "Sales_data: " << sizeof(Sales_data) << "\n"
	     << "Sales_data[3]: " << sizeof(Sales_data[3]) << "\n"
	     << "Sales_data*: " << sizeof(Sales_data*) << "\n"
	     << "Sales_data&: " << sizeof(Sales_data&) << endl;

	cout << "Sales_data::revenue: " << sizeof Sales_data::revenue << "\n"
	     << "data.revenue: " << sizeof data.revenue << endl;

	int x[10];
	int *ip = x;

	// number of elements in x
	cout << sizeof(x)/sizeof(*x) << endl;

	// divides sizeof a pointer by sizeof an int
	cout << sizeof(ip)/sizeof(*ip) << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	char ch;
	while (cin >> ch)
		cout << ch;
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::sort;

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::cin; using std::endl;

#include "Sales_item.h"

int main()
{
    Sales_item trans;
    vector<Sales_item> file;

    while (std::cin >> trans)  // read the transations
        file.push_back(trans);

	for (auto i : file)        // print what was read
		cout << i << endl;
	cout << "\n\n";

	sort(file.begin(), file.end(), compareIsbn); // sort into ISBN order
	for (auto i : file)        // print in ISBN order
		cout << i << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

#include <memory>
using std::unique_ptr; using std::shared_ptr;

// function-object class that calls delete on a given pointer
#include "DebugDelete.h"

int main()
{
	double* p = new double;
	// an object that can act like a delete expression
	DebugDelete d("plain pointer");
	d(p); // calls DebugDelete::operator()(double*), which deletes p

	int* ip = new int;
	// calls operator()(int*) on a temporary DebugDelete object
	DebugDelete("plain pointer")(ip);

	// destroying the the object to which upi points
	// instantiates DebugDelete::operator()<int>(int *)
	unique_ptr<int, DebugDelete> upi(new int, DebugDelete());

	// destroying the the object to which ups points
	// instantiates DebugDelete::operator()<string>(string*)
	unique_ptr<string, DebugDelete> ups(new string, DebugDelete());

	// illustrate other types using DebugDelete as their deleter
	shared_ptr<int> sp1(new int(42), DebugDelete("shared_ptr"));

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <exception>
using std::exception;

// this function will compile, even though it clearly violates its exception specification
void f() noexcept       // promises not to throw any exception
{
    throw exception();  // violates the exception specification
}

void g() { }
void h() noexcept(noexcept(f())) { f(); }
void i() noexcept(noexcept(g())) { g(); }
int main()
{
    try {
		cout << "f: " << std::boolalpha << noexcept(f()) << endl;
		cout << "g: " << std::boolalpha << noexcept(g()) << endl;
		cout << "h: " << std::boolalpha << noexcept(h()) << endl;
		cout << "i: " << std::boolalpha << noexcept(i()) << endl;
        f();
    } catch (exception &e) {
        cout << "caught " << e.what() << endl;
    }

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

// declarations before definitions
template <typename T> void f(T);
template <typename T> void f(const T*);

template <typename T> void g(T);
template <typename T> void g(T*);

// definitions
template <typename T> void f(T) { cout << "f(T)" << endl; }
template <typename T> void f(const T*)
{ cout << "f(const T*)" << endl; }

template <typename T> void g(T) { cout << "g(T)" << endl; }
template <typename T> void g(T*) { cout << "g(T*)" << endl; }

int main()
{
	int i = 42;
	f(i);  // calls f(T), f(const T*) isn't viable

	f(&i); // calls f(T), which is an exact match,
	       // f(const T*) requires a conversion

	g(i);  // calls g(T), g(T*) isn't viable
	g(&i); // calls g(T*), both templates are viable,
	       // but g(T*) is more specialized

	int *p = &i;
	const int ci = 0, *p2 = &ci;
	g(42);   g(p);   g(ci);   g(p2);
	f(42);   f(p);   f(ci);   f(p2);

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	vector<int> v{1,2,3,4,5,6,7,8,9};
	for (auto &i : v) // for each element in v (note: i is a reference)
		i *= i;           // square the element value
	for (auto i : v)      // for each element in v
		cout << i << " "; // print the element
	cout << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::cerr;
using std::istream; using std::ostream; using std::endl;

#include <sstream>
using std::ostringstream; using std::istringstream;

#include <vector>
using std::vector;

#include <string>
using std::string;

// members are public by default
struct PersonInfo {
	string name;
	vector<string> phones;
};

// we'll see how to reformat phone numbers in chapter 17
// for now just return the string we're given
string format(const string &s) { return s; }

bool valid(const string &s)
{
	// we'll see how to validate phone numbers
	// in chapter 17, for now just return true
	return true;
}

vector<PersonInfo>
getData(istream &is)
{
	// will hold a line and word from input, respectively
	string line, word;

	// will hold all the records from the input
	vector<PersonInfo> people;

	// read the input a line at a time until end-of-file (or other error)
	while (getline(is, line)) {
		PersonInfo info;            // object to hold this record's data
	    istringstream record(line); // bind record to the line we just read
		record >> info.name;        // read the name
	    while (record >> word)      // read the phone numbers
			info.phones.push_back(word);  // and store them
		people.push_back(info); // append this record to people
	}

	return people;
}

ostream& process(ostream &os, vector<PersonInfo> people)
{
	for (const auto &entry : people) {    // for each entry in people
		ostringstream formatted, badNums; // objects created on each loop
		for (const auto &nums : entry.phones) {  // for each number
			if (!valid(nums)) {
				badNums << " " << nums;  // string in badNums
			} else
				// ``writes'' to formatted's string
				formatted << " " << format(nums);
		}
		if (badNums.str().empty())      // there were no bad numbers
			os << entry.name << " "     // print the name
			   << formatted.str() << endl; // and reformatted numbers
		else                   // otherwise, print the name and bad numbers
			cerr << "input error: " << entry.name
			     << " invalid number(s) " << badNums.str() << endl;
	}

	return os;
}

int main()
{
	process(cout, getData(cin));

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <deque>
using std::deque;

#include <stack>
using std::stack;

#include <iostream>
using std::cout; using std::cerr; using std::endl;

bool process(int);

int main()
{
	stack<int> intStack;  // empty stack

	// fill up the stack
	for (size_t ix = 0; ix != 10; ++ix)
    	intStack.push(ix);   // intStack holds 0 . . . 9 inclusive

	// while there are still values in intStack
	while (!intStack.empty()) {
    	int value = intStack.top();
    	// code that uses value
		cout << value << endl;
    	intStack.pop(); // pop the top element, and repeat
	}

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::endl; using std::cout;

#include <iterator>
using std::begin; using std::end;

// prints a null-terminated array of characters
void print(const char *cp)
{
	if (cp)          // if cp is not a null pointer
		while (*cp)  // so long as the character it points to is not a null character
			cout << *cp++;  // print the character and advance the pointer
}

// print ints in the given range
void print(const int *beg, const int *end)
{
	// print every element starting at beg up to but not including end
    while (beg != end)
        cout << *beg++ << " "; // print the current element
		                       // and advance the pointer
}

int main()
{
	print("hi world!"); // calls first version of print
	cout << endl;

    // j is converted to a pointer to the first element in j
    // the second argument is a pointer to one past the end of j
    int j[2] = {0, 1};
    print(begin(j), end(j));  // library begin and end functions
	cout << endl;

	// equivalent call, directly calculate the begin and end pointers
	print(j, j + 2);
	cout << endl;

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

int main()
{
    string str = "Hello";
    string phrase = "Hello World";
    string slang  = "Hiya";

    if (str < phrase) cout << "str is smaller" << endl;
    if (slang > str) cout << "slang is greater" << endl;
    if (slang > phrase) cout << "slang is greater" << endl;

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <utility>
// for std::move, but we don't supply a using declaration for move

#include <iostream>
using std::cerr; using std::endl;

#include <set>
using std::set;

#include "StrFolder.h"

void swap(Message &lhs, Message &rhs)
{
	using std::swap;  // not strictly needed in this case, but good habit

	// remove pointers to each Message from their (original) respective Folders
	for (auto f: lhs.folders)
		f->remMsg(&lhs);
	for (auto f: rhs.folders)
		f->remMsg(&rhs);

	// swap the contents and Folder pointer sets
	swap(lhs.folders, rhs.folders);   // uses swap(set&, set&)
	swap(lhs.contents, rhs.contents); // swap(String&, String&)

	// add pointers to each Message to their (new) respective Folders
	for (auto f: lhs.folders)
		f->addMsg(&lhs);
	for (auto f: rhs.folders)
		f->addMsg(&rhs);
}

Folder::Folder(Folder &&f)
{
	move_Messages(&f);   // make each Message point to this Folder
}

Folder& Folder::operator=(Folder &&f)
{
	if (this != &f) {        // direct check for self-assignment
		remove_from_Msgs();  // remove this Folder from the current msgs
		move_Messages(&f);   // make each Message point to this Folder
	}
	return *this;
}

void Folder::move_Messages(Folder *f)
{
	msgs = std::move(f->msgs); // move the set from f to this Folder
	f->msgs.clear();      // ensure that destroying f is harmless
	for (auto m : msgs) { // for each Message in this Folder
		m->remFldr(f);    // remove the pointer to the old Folder
		m->addFldr(this); // insert pointer to this Folder
	}
}

Message::Message(Message &&m): contents(std::move(m.contents))
{
	move_Folders(&m); // moves folders and updates the Folder pointers
}

Message::Message(const Message &m):
    contents(m.contents), folders(m.folders)
{
    add_to_Folders(m); // add this Message to the Folders that point to m
}


Message& Message::operator=(Message &&rhs)
{
	if (this != &rhs) {       // direct check for self-assignment
		remove_from_Folders();
		contents = std::move(rhs.contents); // move assignment
		move_Folders(&rhs); // reset the Folders to point to this Message
	}
    return *this;
}

Message& Message::operator=(const Message &rhs)
{
	// handle self-assignment by removing pointers before inserting them
    remove_from_Folders();    // update existing Folders
    contents = rhs.contents;  // copy message contents from rhs
    folders = rhs.folders;    // copy Folder pointers from rhs
    add_to_Folders(rhs);      // add this Message to those Folders
    return *this;
}

Message::~Message()
{
    remove_from_Folders();
}

// move the Folder pointers from m to this Message
void Message::move_Folders(Message *m)
{
	folders = std::move(m->folders); // uses set move assignment
	for (auto f : folders) {  // for each Folder
		f->remMsg(m);    // remove the old Message from the Folder
		f->addMsg(this); // add this Message to that Folder
	}
	m->folders.clear();  // ensure that destroying m is harmless
}

// add this Message to Folders that point to m
void Message::add_to_Folders(const Message &m)
{
	for (auto f : m.folders) // for each Folder that holds m
        f->addMsg(this); // add a pointer to this Message to that Folder
}

// remove this Message from the corresponding Folders
void Message::remove_from_Folders()
{
	for (auto f : folders)  // for each pointer in folders
		f->remMsg(this);    // remove this Message from that Folder
	folders.clear();        // no Folder points to this Message

}

void Folder::add_to_Messages(const Folder &f)
{
	for (auto msg : f.msgs)
		msg->addFldr(this);   // add this Folder to each Message
}

Folder::Folder(const Folder &f) : msgs(f.msgs)
{
    add_to_Messages(f);  // add this Folder to each Message in f.msgs
}

Folder& Folder::operator=(const Folder &f)
{
    remove_from_Msgs();  // remove this folder from each Message in msgs
	msgs = f.msgs;       // copy the set of Messages from f
    add_to_Messages(f);  // add this folder to each Message in msgs
    return *this;
}

Folder::~Folder()
{
    remove_from_Msgs();
}


void Folder::remove_from_Msgs()
{
    while (!msgs.empty())
        (*msgs.begin())->remove(*this);
}

void Message::save(Folder &f)
{
    folders.insert(&f); // add the given Folder to our list of Folders
    f.addMsg(this);     // add this Message to f's set of Messages
}

void Message::remove(Folder &f)
{
    folders.erase(&f); // take the given Folder out of our list of Folders
    f.remMsg(this);    // remove this Message to f's set of Messages
}

void Folder::save(Message &m)
{
    // add m and add this folder to m's set of Folders
    msgs.insert(&m);
    m.addFldr(this);
}

void Folder::remove(Message &m)
{
    // erase m from msgs and remove this folder from m
    msgs.erase(&m);
    m.remFldr(this);
}

void Folder::debug_print()
{
    cerr << "Folder contains " << msgs.size() << " messages" << endl;
    int ctr = 1;
    for (auto m : msgs) {
        cerr << "Message " << ctr++ << ":\n\t" << m->contents << endl;
	}
}

void Message::debug_print()
{
    cerr << "Message:\n\t" << contents << endl;
    cerr << "Appears in " << folders.size() << " Folders" << endl;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <vector>
using std::vector;

#include "StrFolder.h"

#include "String.h"

int main()
{
	String s1("contents1");
	String s2("contents2");
	String s3("contents3");
	String s4("contents4");
	String s5("contents5");
	String s6("contents6");

	// all new messages, no copies yet
	Message m1(s1);
	Message m2(s2);
	Message m3(s3);
	Message m4(s4);
	Message m5(s5);
	Message m6(s6);

	Folder f1;
	Folder f2;

	m1.save(f1); m3.save(f1); m5.save(f1);
	m1.save(f2);
	m2.save(f2); m4.save(f2); m6.save(f2);

	m1.debug_print();
	f2.debug_print();

	// create some copies
	Message c1(m1);
	Message c2(m2), c4(m4), c6(m6);

	m1.debug_print();
	f2.debug_print();

	// now some assignments
	m2 = m3;
	m4 = m5;
	m6 = m3;
	m1 = m5;

	m1.debug_print();
	f2.debug_print();

	// finally, self-assignment
	m2 = m2;
	m1 = m1;

	m1.debug_print();
	f2.debug_print();

	vector<Message> vm;
	cout << "capacity: " << vm.capacity() << endl;
	vm.push_back(m1);

	cout << "capacity: " << vm.capacity() << endl;
	vm.push_back(m2);

	cout << "capacity: " << vm.capacity() << endl;
	vm.push_back(m3);

	cout << "capacity: " << vm.capacity() << endl;
	vm.push_back(m4);

	cout << "capacity: " << vm.capacity() << endl;
	vm.push_back(m5);

	cout << "capacity: " << vm.capacity() << endl;
	vm.push_back(m6);

	vector<Folder> vf;
	cout << "capacity: " << vf.capacity() << endl;
	vf.push_back(f1);

	cout << "capacity: " << vf.capacity() << endl;
	vf.push_back(f2);

	cout << "capacity: " << vf.capacity() << endl;
	vf.push_back(Folder(f1));

	cout << "capacity: " << vf.capacity() << endl;
	vf.push_back(Folder(f2));

	cout << "capacity: " << vf.capacity() << endl;
	vf.push_back(Folder());

	Folder f3;
	f3.save(m6);
	cout << "capacity: " << vf.capacity() << endl;
	vf.push_back(f3);


	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstring>
using std::strlen;

#include <algorithm>
using std::copy;

#include <cstddef>
using std::size_t;

#include <iostream>
using std::ostream;

#include <utility>
using std::swap;

#include <initializer_list>
using std::initializer_list;

#include <memory>
using std::uninitialized_copy;

#include "String.h"

// define the static allocator member
std::allocator<char> String::a;

// copy-assignment operator
String & String::operator=(const String &rhs)
{
	// copying the right-hand operand before deleting the left handles self-assignment
    auto newp = a.allocate(rhs.sz); // copy the underlying string from rhs
	uninitialized_copy(rhs.p, rhs.p + rhs.sz, newp);

	if (p)
		a.deallocate(p, sz); // free the memory used by the left-hand operand
	p = newp;    // p now points to the newly allocated string
	sz = rhs.sz; // update the size

    return *this;
}

// move assignment operator
String & String::operator=(String &&rhs) noexcept
{
	// explicit check for self-assignment
	if (this != &rhs) {
		if (p)
			a.deallocate(p, sz);  // do the work of the destructor
		p = rhs.p;    // take over the old memory
		sz = rhs.sz;
		rhs.p = 0;    // deleting rhs.p is safe
		rhs.sz = 0;
	}
    return *this;
}

String& String::operator=(const char *cp)
{
	if (p) a.deallocate(p, sz);
	p = a.allocate(sz = strlen(cp));
	uninitialized_copy(cp, cp + sz, p);
	return *this;
}

String& String::operator=(char c)
{
	if(p) a.deallocate(p, sz);
	p = a.allocate(sz = 1);
	*p = c;
	return *this;
}

String& String::operator=(initializer_list<char> il)
{
	// no need to check for self-assignment
	if (p)
		a.deallocate(p, sz);        // do the work of the destructor
	p = a.allocate(sz = il.size()); // do the work of the copy constructor
	uninitialized_copy(il.begin(), il.end(), p);
	return *this;
}
// named functions for operators
ostream &print(ostream &os, const String &s)
{
	auto p = s.begin();
	while (p != s.end())
		os << *p++ ;
	return os;
}

String add(const String &lhs, const String &rhs)
{
	String ret;
	ret.sz = rhs.size() + lhs.size();   // size of the combined String
	ret.p = String::a.allocate(ret.sz); // allocate new space
	uninitialized_copy(lhs.begin(), lhs.end(), ret.p); // copy the operands
	uninitialized_copy(rhs.begin(), rhs.end(), ret.p + lhs.sz);
	return ret;  // return a copy of the newly created String
}

// return plural version of word if ctr isn't 1
String make_plural(size_t ctr, const String &word,
                               const String &ending)
{
        return (ctr != 1) ?  add(word, ending) : word;
}

// chapter 14 will explain overloaded operators
ostream &operator<<(ostream &os, const String &s)
{
	return print(os, s);
}

String operator+(const String &lhs, const String &rhs)
{
	return add(lhs, rhs);
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

int main()
{

	string s1  = "hello, ", s2 = "world\n";
	string s3 = s1 + s2;   // s3 is hello, world\n
	cout << s1 << s2 << s3 << endl;

	s1 += s2;   // equivalent to s1 = s1 + s2
	cout << s1;

	string s4 = "hello", s5 = "world";  // no punctuation in s4 or s2
	string s6 = s4 + ", " + s5 + '\n';
	cout << s4 << s5 << "\n" << s6 << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cin;
using std::cout;
using std::endl;

int main()
{
    string s;          // empty string
    cin >> s;          // read a whitespace-separated string into s
    cout << s << endl; // write s to the output
    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	string s1, s2;

	cin >> s1 >> s2; // read first input into s1, second into s2
	cout << s1 << s2 << endl; // write both strings

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

string st1;       // empty string
string st2(st1);  // st2 is a copy of st1

int main()
{
    string st("The expense of spirit\n");
    cout << "The size of " << st << "is " << st.size()
         << " characters, including the newline" << endl;
    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <string>
using std::string; using std::getline;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	string line;

	// read input a line at a time and print lines that are longer than 80 characters
	while (getline(cin, line))
		if (line.size() > 80)
			cout << line << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string; using std::getline;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	string line;

	// read input a line at a time and discard blank lines
	while (getline(cin, line))
		if (!line.empty())
			cout << line << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "StrVec.h"

#include <string>
using std::string;

#include <memory>
using std::allocator;

// errata fixed in second printing --
// StrVec's allocator should be a static member not an ordinary member

// definition for static data member
allocator<string> StrVec::alloc;

// all other StrVec members are inline and defined inside StrVec.h
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::endl;


int main()
{
	string s = "some string", s2 = "some other string";
	// equivalent ways to insert all the characters from s2 at beginning of s
	// insert iterator range before s.begin()
	s.insert(s.begin(), s2.begin(), s2.end());
	cout << "insert iterators version:        " << s << endl;

	s = "some string";
	s.insert(0, s2); // insert a copy of s2 before position 0 in s
	cout << "insert string at given position: " << s << endl;

	s = "some string";
	// insert s2.size() characters from s2 starting at s2[0] before s[0]
	s.insert(0, s2, 0, s2.size());
	cout << "insert positional version:       " << s << endl;


	s = "";  // s is now empty
	vector<char> c_vec(1, 'a');
	// insert characters from c_vec into s
	s.insert(s.begin(), c_vec.begin(), c_vec.end());
	s.insert(s.size(), 5, '!'); // add five exclamation points at the end of s
	cout << s << endl;

	s.erase(s.size() - 5, 5);   // erase the last five characters from s
	cout << s << endl;

	s = "";  // s is now empty
	const char *cp = "Stately, plump Buck";
	s.assign(cp, 7);            // s == "Stately"
	cout << s << endl;
	s.insert(s.size(), cp + 7); // s == "Stately, plump Buck"
	cout << s << endl;

	s = "C++ Primer";  // reset s and s2
	s2 = s;            // to "C++ Primer"
	s.insert(s.size(), " 4th Ed."); // s == "C++ Primer 4th Ed."
	s2.append(" 4th Ed."); // equivalent: appends " 4th Ed." to s2;
	cout << s << " " << s2 << endl;

	// two ways to replace "4th" by "5th"
	// 1. insert and erase
	s.erase(11, 3);                 // s == "C++ Primer Ed."
	s.insert(11, "5th");            // s == "C++ Primer 5th Ed."

	// 2. use replace
	// erase three characters starting at position 11
	//  and then insert "5th"
	s2.replace(11, 3, "5th"); // equivalent: s == s2

	cout << s << " " << s2 << endl;

	// two ways to replace "5th" by "Fifth"
	// 1. use replace if we know where the string we want to replace is
	s.replace(11, 3, "Fifth"); // s == "C++ Primer Fifth Ed."

	// 2. call find first to get position from which to replace
	auto pos = s2.find("5th");
	if (pos != string::npos)
		s2.replace(pos, 3, "Fifth");
	else
		cout << "something's wrong, s2 is: " << s2 << endl;
	cout << s << " " << s2 << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Version_test.h"

// if the regular expression library isn't support, do nothing
#ifdef REGEX

#include <string>
using std::string;

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <regex>
using std::regex; using std::sregex_iterator; using std::smatch;
using std::regex_error;

int main()
{
	try {
		// r has two subexpressions:
		// the first is the part of the file name before the period
		// the second is the file extension
		regex r("([[:alnum:]]+)\\.(cpp|cxx|cc)$", regex::icase);
		smatch results;
		string filename;
		while (cin >> filename)
			if (regex_search(filename, results, r))
				cout << results.str(1) << endl;
				// print the first subexpression
	} catch (regex_error e)
		{ cout << e.what() << " " << e.code() << endl; }

	return 0;
}
#else

// do nothing
int main() { return 0; }

#endif

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

string::size_type
position(const string &a, const string &b, const string &c)
{
	return (a + b).find(c);
}

int main()
{
	string s1 = "a value", s2 = "another";
	auto x = position(s1, s2, "val");
	if (x == string::npos)
		cout << "not found" << endl;
	else if (x < s1.size())
		cout << "value is in first parameter" << endl;
	else
		cout << "value is in second parameter" << endl;

	auto n = (s1 + s2).find('a');
	cout << "n = " << n << endl;
	s1 + s2 = "wow!";
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include <stdexcept>
using std::out_of_range;

int main()
{
	try {
		string s("hello world");
		cout << s.substr(0, 5) << endl;  // prints hello
		cout << s.substr(6) << endl;     // prints world
		cout << s.substr(6, 11) << endl; // prints world
		cout << s.substr(12) << endl;    // throws out_of_range
	} catch(out_of_range) {cout << "caught out_of_range" << endl; }

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "TextQuery.h"
#include "make_plural.h"

#include <cstddef>
#include <memory>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <iostream>
#include <fstream>
#include <cctype>
#include <cstring>
#include <utility>

using std::size_t;
using std::shared_ptr;
using std::istringstream;
using std::string;
using std::getline;
using std::vector;
using std::map;
using std::set;
using std::cerr;
using std::cout;
using std::cin;
using std::ostream;
using std::endl;
using std::ifstream;
using std::ispunct;
using std::tolower;
using std::strlen;
using std::pair;

// read the input file and build the map of lines to line numbers
TextQuery::TextQuery(ifstream &is): file(new vector<string>)
{
    string text;
    while (getline(is, text)) {       // for each line in the file
		file->push_back(text);        // remember this line of text
		int n = file->size() - 1;     // the current line number
		istringstream line(text);     // separate the line into words
		string word;
		while (line >> word) {        // for each word in that line
            word = cleanup_str(word);
            // if word isn't already in wm, subscripting adds a new entry
            auto &lines = wm[word]; // lines is a shared_ptr
            if (!lines) // that pointer is null the first time we see word
                lines.reset(new set<line_no>); // allocate a new set
            lines->insert(n);      // insert this line number
		}
	}
}

// not covered in the book -- cleanup_str removes
// punctuation and converts all text to lowercase so that
// the queries operate in a case insensitive manner
string TextQuery::cleanup_str(const string &word)
{
    string ret;
    for (auto it = word.begin(); it != word.end(); ++it) {
        if (!ispunct(*it))
            ret += tolower(*it);
    }
    return ret;
}

QueryResult
TextQuery::query(const string &sought) const
{
	// we'll return a pointer to this set if we don't find sought
	static shared_ptr<set<line_no>> nodata(new set<line_no>);

    // use find and not a subscript to avoid adding words to wm!
    auto loc = wm.find(cleanup_str(sought));

	if (loc == wm.end())
		return QueryResult(sought, nodata, file);  // not found
	else
		return QueryResult(sought, loc->second, file);
}

ostream &print(ostream & os, const QueryResult &qr)
{
    // if the word was found, print the count and all occurrences
    os << qr.sought << " occurs " << qr.lines->size() << " "
       << make_plural(qr.lines->size(), "time", "s") << endl;

    // print each line in which the word appeared
	for (auto num : *qr.lines) // for every element in the set
		// don't confound the user with text lines starting at 0
        os << "\t(line " << num + 1 << ") "
		   << *(qr.file->begin() + num) << endl;

	return os;
}

// debugging routine, not covered in the book
void TextQuery::display_map()
{
    auto iter = wm.cbegin(), iter_end = wm.cend();

    // for each word in the map
    for ( ; iter != iter_end; ++iter) {
        cout << "word: " << iter->first << " {";

        // fetch location vector as a const reference to avoid copying it
        auto text_locs = iter->second;
        auto loc_iter = text_locs->cbegin(),
                        loc_iter_end = text_locs->cend();

        // print all line numbers for this word
        while (loc_iter != loc_iter_end)
        {
            cout << *loc_iter;

            if (++loc_iter != loc_iter_end)
                 cout << ", ";

         }

         cout << "}\n";  // end list of output this word
    }
    cout << endl;  // finished printing entire map
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include "Token.h"

int main()
{
	Token token;
	Token t2;
	Token t3;
	cout << t2 << " " << t3 << endl;
	t2 = string("hi mom!");
	t3 = "good bye";
	token = t2;
	token = "boo";
	cout << token << endl;
	t2 = t3;
	cout << t2 << endl;

	token = 42;
	cout << token << endl;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <type_traits>
using std::remove_reference;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include "Blob.h"

// auto as function return type indicates we're using a trailing return type
// function that returns a reference to an element in the range
template <typename It>
auto reffcn(It beg, It end) -> decltype(*beg)
{
    // process the range
    return *beg;  // return a copy of an element from the range
}

// function that returns an element in the range by value
// must use typename to use a type member of a template parameter
template <typename It>
auto valfcn(It beg, It end) ->
	typename remove_reference<decltype(*beg)>::type
{
    // process the range
    return *beg;  // return a copy of an element from the range
}

int main()
{
	vector<int> vi = {1,2,3,4,5};
	Blob<string> ca = { "hi", "bye" };

	auto &i = reffcn(vi.begin(), vi.end()); // reffcn should return int&
	auto &s = reffcn(ca.begin(), ca.end()); // reffcn should return string&

	vi = {1,2,3,4};
	for (auto i : vi) cout << i << " "; cout << endl;
	auto &ref = reffcn(vi.begin(), vi.end());  // ref is int&
	ref = 5; // changes the value of *beg to which ref refers
	for (auto i : vi) cout << i << " "; cout << endl;

	auto val = valfcn(vi.begin(), vi.end()); // val is int
	cout << val << endl;  // will print 5

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <list>
using std::list;

#include <vector>
using std::vector;

#include <tuple>
using std::tuple; using std::get;
using std::tuple_size; using std::tuple_element;
using std::make_tuple;

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	// tuple that represents a bookstore transaction:
	// ISBN, count, price per book
	auto item = make_tuple("0-999-78345-X", 3, 20.00);
	auto book = get<0>(item);      // returns the first member of item
	auto cnt = get<1>(item);       // returns the second member of item
	auto price = get<2>(item)/cnt; // returns the last member of item
	get<2>(item) *= 0.8;           // apply 20% discount

	cout << book << " " << cnt << " " << price << endl;

	typedef decltype(item) trans; // trans is the type of item

	// returns the number of members in object's of type trans
	size_t sz = tuple_size<trans>::value;  // returns 3

	// cnt has the same type as the second member in item
	tuple_element<1, trans>::type cnt2 = get<1>(item); // cnt is an int
	tuple_element<0, trans>::type book2 = get<0>(item);
	tuple_element<2, trans>::type price2 = get<2>(item);
	cout << tuple_size<trans>::value << endl;

	cout << book2 << " " << cnt2 << " " << price2 << endl;

	tuple<size_t, size_t, size_t> threeD;  // all three members set to 0
	tuple<string, vector<double>, int, list<int>>
	    someVal("constants", {3.14, 2.718}, 42, {0,1,2,3,4,5});

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Blob.h"

#include <utility>
using std::pair;

#include <string>
using std::string;

typedef Blob<string> StrBlob;


template<typename T> using twin = pair<T, T>;

template <typename T> using partNo = pair<T, unsigned>;

int main()
{
	// authors is a pair<string, string>
	twin<string> author("Mark", "Twain");

	twin<int> win_loss(2, 45);  // win_loss is a pair<int, int>

	typedef string Vehicle;
	partNo<Vehicle> car("volvo", 242);  // car is a pair<Vehicle, unsigned>

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Sales_data.h"

#include <iostream>
using std::cout; using std::endl;

#include <typeinfo>

#include <string>
using std::string;

struct Base {
    virtual ~Base() { }
};

struct Derived : Base { };

int main()
{
	int arr[10];
	Derived d;
	Base *p = &d;

	cout << typeid(42).name() << ", "
	     << typeid(arr).name() << ", "
	     << typeid(Sales_data).name() << ", "
	     << typeid(std::string).name() << ", "
	     << typeid(p).name() << ", "
	     << typeid(*p).name() << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

int main()
{
	int i = 1024;
	int k = -i; // i is -1024

	bool b = true;
	bool b2 = -b; // b2 is true!

	cout << b << " " << b2 << " " << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <iostream>
using std::ostream; using std::cin; using std::cout; using std::endl;

#include <memory>
using std::shared_ptr;

int main() {
	shared_ptr<string> p(new string("Hello!"));
	shared_ptr<string> p2(p);    // two users of the allocated string
	string newVal;
	if (!p.unique())
		p.reset(new string(*p)); // we aren't alone; allocate a new copy
	*p += newVal; // now that we know we're the only pointer, okay to change this object
	cout << *p << " " << *p2 << endl;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <unordered_map>
using std::unordered_map;

#include <unordered_set>
using std::unordered_set; using std::unordered_multiset;

#include <string>
using std::string;

using std::hash;

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <cstddef>
using std::size_t;

#include "Sales_data.h"

// unordered_map version of the word count program
int main()
{
	// count occurrences, but the words won't be in alphabetical order
    unordered_map<string, size_t> word_count;
    string word;
    while (cin >> word)
		++word_count[word]; // fetch and increment the counter for word

	for (const auto &w : word_count) // for each element in the map
		// print the results
		cout <<  w.first << " occurs " << w.second
		     << ((w.second > 1) ? " times" : " time") << endl;

	return 0;
}

// how to override default hash and equality operator on key_type
size_t hasher(const Sales_data &sd)
{
	return hash<string>()(sd.isbn());
}
bool eqOp(const Sales_data &lhs, const Sales_data &rhs)
{
	return lhs.isbn() == rhs.isbn();
}

// type alias using our functions in place of hash<key_type> and ==
using SD_multiset = unordered_multiset<Sales_data,
                    decltype(hasher)*, decltype(eqOp)*>;

// bookstore can hold multiple Sales_data with the same ISBN
// arguments are the bucket size
// and pointers to the hash function and equality operator
SD_multiset bookstore(42, hasher, eqOp);

// how to override just the hash function;
// Foo must have ==
struct Foo { string s; };

// we'll see how to define our own operators in chapter 14
bool operator==(const Foo& l, const Foo&r) { return l.s == r.s; }

size_t FooHash(const Foo& f) { return hash<string>()(f.s); }

// use FooHash to generate the hash code; Foo must have an == operator
unordered_set<Foo, decltype(FooHash)*> fooSet(10, FooHash);

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>

int main()
{
	unsigned u = 10, u2 = 42;
	std::cout << u2 - u << std::endl;
	std::cout << u - u2 << std::endl;

	int i = 10, i2 = 42;
	std::cout << i2 - i << std::endl;
	std::cout << i - i2 << std::endl;

	u = 42;
	i = 10;
	std::cout << i - u << std::endl;
	std::cout << u - i << std::endl;

	u = 10;
	i = -42;
	std::cout << i + i << std::endl;  // prints -84
	std::cout << u + i << std::endl;  // if 32-bit ints, prints 4294967264

	i = 10;
	std::cout << "good" << std::endl;
	while (i >= 0) {
		std::cout << i << std::endl;
		--i;
	}

	for (int i = 10; i >= 0; --i)
		std::cout << i << std::endl;

	for (unsigned u = 0; u <= 10; ++u)
		std::cout << u << std::endl;  // prints 0 . . . 10

/* NOTE: the condition in the following loop
         will run indefinitely
	// WRONG: u can never be less than 0; the condition will always succeed
	for (unsigned u = 10; u >= 0; --u)
    	std::cout << u << std::endl;
*/
	u = 11; // start the loop one past the first element we want to print
	while (u > 0) {
		 --u;        // decrement first, so that the last iteration will print 0
		std::cout << u << std::endl;
	}

	// be wary of comparing ints and unsigned
	u = 10;
	i = -42;
	if (i < u)               // false: i is converted to unsigned
		std::cout << i << std::endl;
	else
		std::cout << u << std::endl;   // prints 10

	u = 42; u2 = 10;
	std::cout << u - u2 << std::endl; // ok: result is 32
	std::cout << u2 - u << std::endl; // ok: but the result will wrap around
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <memory>
using std::unique_ptr; using std::shared_ptr;

int main()
{
	// up points to an array of ten uninitialized ints
	unique_ptr<int[]> up(new int[10]);
	for (size_t i = 0; i != 10; ++i)
		up[i] = i;  // assign a new value to each of the elements
	up.release();   // automatically uses delete[] to destroy its pointer

	// to use a shared_ptr we must supply a deleter
	shared_ptr<int> sp(new int[10], [](int *p) { delete[] p; });
	// shared_ptrs don't have subscript operator
	// and don't support pointer arithmetic
	for (size_t i = 0; i != 10; ++i)
		*(sp.get() + i) = i;  // use get to get a built-in pointer
	sp.reset(); // uses the lambda we supplied
	            // that uses delete[] to free the array
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::copy;

#include <iterator>
using std::istream_iterator; using std::ostream_iterator;

#include <vector>
using std::vector;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main() {
	vector<int> vec;
	istream_iterator<int> in_iter(cin);  // read ints from cin
	istream_iterator<int> eof;           // istream ``end'' iterator

	// use in_iter to read cin storing what we read in vec
	while (in_iter != eof)  // while there's valid input to read
		// postfix increment reads the stream and
		// returns the old value of the iterator
		// we dereference that iterator to get
		// the previous value read from the stream
		vec.push_back(*in_iter++);

	// use an ostream_iterator to print the contents of vec
	ostream_iterator<int> out_iter(cout, " ");
	copy(vec.begin(), vec.end(), out_iter);
	cout << endl;

	// alternative way to print contents of vec
	for (auto e : vec)
		*out_iter++ = e;  // the assignment writes this element to cout
	cout << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

#include "Account.h"

int main()
{
	Account a1("bem", 42);
	cout << a1.balance() << endl;
	a1.calculate();
	cout << a1.balance() << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <memory>
using std::allocator;

#include <cstddef>
using std::size_t;

#include <iostream>
using std::cout; using std::endl;

#include <fstream>
using std::ifstream;

int main()
{
	const size_t n = 100;
	allocator<string> alloc;      // object that can allocate strings
	auto p = alloc.allocate(n);   // allocate n unconstructed strings

	auto q = p; // q will point to one past the last constructed element
	alloc.construct(q++);         // *q is the empty string
	cout << *(q-1) << endl;

	alloc.construct(q++, 10, 'c'); // *q is cccccccccc
	cout << *(q - 1) << endl;

	alloc.construct(q++, "hi");    // *q is hi!
	cout << *(q - 1) << endl;

	cout << *p << endl;  // ok: uses the string output operator
	while (q != p)
		alloc.destroy(--q);  // free the strings we actually allocated

	alloc.deallocate(p, n);  // return the memory we allocated

	p = alloc.allocate(n);   // allocate n unconstructed strings
	string s;
	q = p;                   // q points to the memory for first string
	ifstream in("data/storyDataFile");
	while (in >> s && q != p + n)
		alloc.construct(q++, s); // construct only as many strings as we need
	size_t size = q - p;         // remember how many strings we read

	// use the array

	cout << "read " << size << " strings" << endl;

	for (q = p + size - 1; q != p; --q)
		alloc.destroy(q);         // free the strings we allocated
	alloc.deallocate(p, n);       // return the memory we allocated

	in.close();
	in.open("data/storyDataFile");
	p = new string[n];            // construct n empty strings
	q = p;                        // q points to the first string
	while (in >> s && q != p + n)
		*q++ = s;                 // assign a new value to *q
	size = q - p;                 // remember how many strings we read

	cout << "read " << size << " strings" << endl;

	// use the array

	delete[] p;  // p points to an array; must remember to use delete[]
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <string>
using std::string;

#include <vector>
using std::vector;

#include <memory>
using std::uninitialized_copy;
using std::allocator; using std::uninitialized_fill_n;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	vector<int> vi{1,2,3,4,5,6,7,8,9};

	allocator<int> alloc;
	// allocate twice as many elements as vi holds
	auto p = alloc.allocate(vi.size() * 2);

	// construct elements starting at p as copies of elements in vi
	auto q = uninitialized_copy(vi.begin(), vi.end(), p);

	// initialize the remaining elements to 42
	uninitialized_fill_n(q, vi.size(), 42);

	for (size_t i = 0; i != vi.size(); ++i)
		cout << *(p + i) << " ";
	cout << endl;

	for (size_t i = 0; i != vi.size(); ++i)
		cout << *(q + i) << " ";
	cout << endl;

	alloc.deallocate(p, vi.size());
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include "Blob.h"

int main()
{
	Blob<string> b1; // empty Blob
	cout << b1.size() << endl;
	{  // new scope
		Blob<string> b2 = {"a", "an", "the"};
		b1 = b2;  // b1 and b2 share the same elements
		b2.push_back("about");
		cout << b1.size() << " " << b2.size() << endl;
	} // b2 is destroyed, but the elements it points to must not be destroyed
	cout << b1.size() << endl;
	for(auto p = b1.begin(); p != b1.end(); ++p)
		cout << *p << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced. Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/
#include <iostream>
using std::cout; using std::endl;

#include "StrBlob.h"

int main()
{
	StrBlob b1;
	{
	    StrBlob b2 = { "a", "an", "the" };
	    b1 = b2;
	    b2.push_back("about");
		cout << b2.size() << endl;
	}
	cout << b1.size() << endl;

	for (auto it = b1.begin(); neq(it, b1.end()); it.incr())
		cout << it.deref() << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Blob.h"
#include <string>
using std::string;

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	vector<int> v1(3, 43), v2(10);
	Blob<int> a1(v1.begin(), v1.end()),
	          a2 = {0,1,2,3,4,5,6,7,8,9},
	          a3(v2.begin(), v2.end());

	cout << a1 << "\n\n" << a2 << "\n\n" << a3 << endl;

	cout << "\ncopy" << "\n\n";
	Blob<int> a5(a1);
	cout << a5 << endl;

	cout << "\nassignment" << "\n\n";

	a1 = a3;
	cout << a1 << "\n\n" << a2 << "\n\n" << a3 << endl;

	cout << "\nelement assignment" << "\n\n";
	a1[0] = 42;
	a1[a1.size() - 1] = 15;
	cout << a1 << "\n\n" << a3 << endl;

	Blob<string> s1 = {"hi", "bye", "now"};
	BlobPtr<string> p(s1);    // p points to the vector inside s1
	*p = "okay";                 // assigns to the first element in s1
	cout << p->size() << endl;   // prints 4, the size of the first element in s1
	cout << (*p).size() << endl; // equivalent to p->size()

	Blob<string> s2{"one", "two", "three"};
	// run the string empty function in the first element in s2
	if (s2[0].empty())
	    s2[0] = "empty"; // assign a new value to the first string in s2

	cout << a1 << endl;
	cout << a2 << endl;
	a2.swap(a1);
	cout << a1 << endl;
	cout << a2 << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

// Version_test.h contains definitions for to_string and stod
// if the compiler does not yet define these functions,
// this code will use the definitions we provide
#include "Version_test.h"

#include <string>
using std::string;
#ifdef STRING_NUMERIC_CONVS
using std::to_string; using std::stod;
#endif

#include <iostream>
using std::cout; using std::endl;

int main()
{
	int i = 42;
	// converts the int i to its character representation
	string s = to_string(i);

	double d = stod(s);   // converts the string s to floating-point
	cout << "i = " << i << " s = " << s << " d is: " << d << endl;

	// convert the first substring in s that starts with a digit,  d = 3.14
	string s2 = "pi = 3.14";
	d = stod(s2.substr(s2.find_first_of("+-.0123456789")));

	cout << "d = " << d << " s = " << s << " s2 is: " << s2 << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cerr; using std::endl;

#include "Debug.h"

int main()
{
	constexpr Debug io_sub(false, true, false);  // debugging IO
	if (io_sub.any())  // equivalent to if(true)
		cerr << "print appropriate error messages" << endl;

	constexpr Debug prod(false); // no debugging during production
	if (prod.any())    // equivalent to if(false)
		cerr << "print an error message" << endl;

	IO_Subsystem ioErrs;        // by default, don't print any debugging
	// no debugging here
	if (ioErrs.default_debug()) // if (false || debug.any())
		cerr << "print message 3" << endl;
	ioErrs.set_debug(true);     // turn on debugging
	if (ioErrs.default_debug()) // if (false || debug.any())
		cerr << "print message 4" << endl;
	ioErrs.set_debug(false);    // okay, debugging section complete

	HW_Subsystem hw;
	hw.set_debug(true);
	if (ioErrs.default_debug() || hw.default_debug()) // if (false || debug.any())
		cerr << "print message 5" << endl;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <vector>
using std::vector;

// function to return minimum element in an vector of ints
int min_element(vector<int>::iterator,
                vector<int>::iterator);

// pointer to function, initialized to point to min_element
int (*pf)(vector<int>::iterator, vector<int>::iterator)
        = min_element;

int main()
{
    vector<int> ivec;
    // give ivec some values
    cout << "Direct call: "
         << min_element(ivec.begin(), ivec.end()) << endl;

    cout << "Indirect call: "
         << pf(ivec.begin(), ivec.end()) << endl;

	cout << "equivalent indirect call: "
	     << (*pf)(ivec.begin(), ivec.end()) << endl;

    return 0;
}

// returns minimum element in an vector of ints
int min_element(vector<int>::iterator beg,
                vector<int>::iterator end) {
    int minVal = 0;
    while (beg != end) {
        if (minVal > *beg)
            minVal = *beg;
        ++beg;
    }
    return minVal;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::ostream;

#include "Quote.h"

int main()
{
	Quote base("0-201-82470-1", 50);
	print_total(cout, base, 10);    // calls Quote::net_price

	Bulk_quote derived("0-201-82470-1", 50, 5, .19);
	print_total(cout, derived, 10); // calls Bulk_quote::net_price

	Quote *baseP = &derived;

	// calls the version from the base class
	// regardless of the dynamic type of baseP
	double undiscounted = baseP->Quote::net_price(42);
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced. Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Screen.h"

#include <functional>
using std::function;

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

struct X {
	int foo(int i) { cout << "foo(" << i << ")" << endl; return i; }
};

void xfcn()
{
	function<int (X*, int)> f;
	f = &X::foo;		// pointer to member

	X x;
	int v = f(&x, 5);
	cout << "v = " << v << endl;
}

int main ()
{
	// pdata can point to a string member of a const (or nonconst) Screen
	const string Screen::*pdata;  // uninitialized
	pdata = &Screen::contents;    // points to the contents member
	auto pdata2 = &Screen::contents; // equivalent declaration

	// data() returns a pointer to the contents member of class Screen
	const string Screen::*pdata3 = Screen::data();

	// Screen objects
	Screen myScreen, *pScreen = &myScreen;
	const Screen cScreen, *pcScreen = &cScreen;

	// .* dereferences pdata to fetch the contents member
	// from the object myScreen
	auto str = myScreen.*pdata;  // s is a string
	auto cstr = cScreen.*pdata;  // c is a const string

	// ->* dereferences pdata to fetch contents
	// from the object to which pScreen points
	str = pScreen->*pdata;

	// pmf is a pointer that can point to a Screen member function
	// that takes no arguments, returns a char, and is const
	// that returns a char and takes no arguments
	auto pmf = &Screen::get_cursor;
	char (Screen::*pmf2)() const = &Screen::get; // same type as pmf

	pmf = &Screen::get; // which version of get deduced from type of pmf
	pmf2 = &Screen::get_cursor;

	Screen s;
	char c1 = s.get_cursor(); // gets character at the cursor directly
	char c2 = (s.*pmf2)();    // calls get_cursor indirectly through pmf2

	// call the function to which pmf points
	// on the object to which pScreen points
	c1 = (pScreen->*pmf)();

	// pmf3 points to the two-parameter version of get
	char (Screen::*pmf3)(Screen::pos, Screen::pos) const = &Screen::get;
	c1 = myScreen.get(0,0);     // call two-parameter version of get
	c2 = (myScreen.*pmf3)(0,0); // equivalent call to get

	// Op is a type that can point to a member function of Screen
	// that returns a char and takes two pos arguments
	using Op = char (Screen::*)(Screen::pos, Screen::pos) const;
	// equivalent declaration of Op using a typedef
	typedef char (Screen::*Op)(Screen::pos, Screen::pos) const;

	Op get = &Screen::get; // get points to the get member of Screen

	myScreen.move(Screen::HOME);  // invokes myScreen.home
	myScreen.move(Screen::DOWN);  // invokes myScreen.down

	// bind an object of type function to a pointer to member
	function<char (const Screen*)> f = &Screen::get_cursor;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

#include "Screen.h"

int main()
{
	Screen myScreen(5,3);
	// move the cursor to a given position, and set that character
	myScreen.move(4,0).set('#');

	Screen nextScreen(5, 5, 'X');
	nextScreen.move(4,0).set('#').display(cout);
	cout << "\n";
	nextScreen.display(cout);
	cout << endl;

	const Screen blank(5, 3);
	myScreen.set('#').display(cout);  // calls nonconst version
	cout << endl;
	blank.display(cout);              // calls const version
	cout << endl;

	myScreen.clear('Z').display(cout); cout << endl;
	myScreen.move(4,0);
	myScreen.set('#');
	myScreen.display(cout); cout << endl;
	myScreen.clear('Z').display(cout); cout << endl;

	// if move returns Screen not Screen&
	Screen temp = myScreen.move(4,0); // the return value would be copied
	temp.set('#'); // the contents inside myScreen would be unchanged
	myScreen.display(cout);
	cout << endl;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "StrVec.h"

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;
using std::istream;

#include <fstream>
using std::ifstream;

void print(const StrVec &svec)
{
	for (auto it : svec)
		cout << it << " " ;
	cout <<endl;
}

StrVec getVec(istream &is)
{
	StrVec svec;
	string s;
	while (is >> s)
		svec.push_back(s);
	return svec;
}

int main()
{
	StrVec sv = {"one", "two", "three"};
	// run the string empty funciton on the first element in sv
	if (!sv[0].empty())
		sv[0] = "None"; // assign a new value to the first string

	// we'll call getVec a couple of times
	// and will read the same file each time
	ifstream in("data/storyDataFile");
	StrVec svec = getVec(in);
	print(svec);
	in.close();

	cout << "copy " << svec.size() << endl;
	auto svec2 = svec;
	print(svec2);

	cout << "assign" << endl;
	StrVec svec3;
	svec3 = svec2;
	print(svec3);

	StrVec v1, v2;
	v1 = v2;                   // v2 is an lvalue; copy assignment

	in.open("data/storyDataFile");
	v2 = getVec(in);          // getVec(in) is an rvalue; move assignment
	in.close();

	StrVec vec;  // empty StrVec
	string s = "some string or another";
	vec.push_back(s);      // calls push_back(const string&)
	vec.push_back("done"); // calls push_back(string&&)

	// emplace member covered in chpater 16
	s = "the end";
	vec.emplace_back(10, 'c'); // adds cccccccccc as a new last element
	vec.emplace_back(s);  // uses the string copy constructor
	string s1 = "the beginning", s2 = s;
	vec.emplace_back(s1 + s2); // uses the move constructor

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <algorithm>
using std::find;

#include <iterator>
using std::begin; using std::end;

#include <vector>
using std::vector;

#include <list>
using std::list;

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

int main()
{
	int ia[] = {27, 210, 12, 47, 109, 83};
	int val = 83;
	int* result = find(begin(ia), end(ia), val);
	cout << "The value " << val
	     << (result == end(ia)
	           ? " is not present" : " is present") << endl;

	// search starting from ia[1] up to but not including ia[4]
	result = find(ia + 1, ia + 4, val);

	// initialize the vector with some values
	vector<int> vec = {27, 210, 12, 47, 109, 83};
	val = 42; // value we'll look for

	// result2 will denote the element we want if it's in vec,
	// or vec.cend() if not
	auto result2 = find(vec.cbegin(), vec.cend(), val);

	// report the result
	cout << "The value " << val
	     << (result2 == vec.cend()
	           ? " is not present" : " is present") << endl;

	// now use find to look in a list of strings
	list<string> lst = {"val1", "val2", "val3"};

	string sval = "a value";  // value we'll look for
	// this call to find looks through string elements in a list
	auto result3 = find(lst.cbegin(), lst.cend(), sval);
	cout << "The value " << sval
	     << (result3 == lst.cend()
	           ? " is not present" : " is present") << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

// return the plural version of word if ctr is greater than 1
string make_plural(size_t ctr, const string &word,
                               const string &ending)
{
	return (ctr > 1) ? word + ending : word;
}

int main()
{
	size_t cnt = 1;
	cout << make_plural(cnt, "success", "es") << endl;
	cnt = 2;
	cout << make_plural(cnt, "failure", "s") << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

// namespace A and function f are defined at global scope
namespace A {
    int i = 0, j = 42;
}

void f()
{
    using namespace A; // injects the names from A into the global scope

	// uses i and j from namespace A
    cout << "i: " << i << " j: " << j << endl;
}

namespace blip {
    int i = 16, j = 15, k = 23;
	void f()
		{ cout << "i: " << i << " j: " << j << " k: " << k << endl; }
}

int j = 0;  // ok: j inside blip is hidden inside a namespace

int main()
{
    // using directive;
	// the names in blip are ``added'' to the global scope
    using namespace blip; // clash between ::j and blip::j
                          // detected only if j is used

    ++i;        // sets blip::i to 17
    ++::j;      // ok: sets global j to 1
    ++blip::j;  // ok: sets blip::j to 16

    int k = 97; // local k hides blip::k
    ++k;        // sets local k to 98

	::f();
	blip::f();
	cout << "j: " << ::j << " k: " << k << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Version_test.h"

// if the regular expression library isn't support, do nothing
#ifdef REGEX

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <string>
using std::string;

#include <regex>
using std::regex; using std::sregex_iterator; using std::smatch;
using std::regex_error;

// the area code doesn't have a separator;
// the remaining separators must be equal
// OR the area code parens are correct and
// the next separator is blank or missing
bool valid(const smatch& m)
{
	// if there is an open parenthesis before the area code
	if(m[1].matched)
		// the area code must be followed by a close parenthesis
		// and followed immediately by the rest of the number or a space
	    return m[3].matched
		       && (m[4].matched == 0 || m[4].str() == " ");
	else
		// then there can't be a close after the area code
		// the delimiters between the other two components must match
		return !m[3].matched
		       && m[4].str() == m[6].str();
}
int main()
{
	// phone has 10 digits, optional parentheses around the area code
	// components are separated by an optional space, ',' or '-'
	string phone = "\\(?\\d{3}\\)?[-. ]?\\d{3}[-. ]?\\d{4}";

	// our overall expression has seven subexpressions:
	//    ( ddd ) separator ddd separator dddd
	// subexpressions 1, 3, 4, and 6 are optional;
	// subexpressions 2, 5, and 7 hold the number
	phone = "(\\()?(\\d{3})(\\))?([-. ])?(\\d{3})([-. ]?)(\\d{4})";
	regex r(phone);  // a regex to find our pattern
	smatch m;        // a match object to hold the results
	string s;        // a string to search

	// read each record from the input file
	while (getline(cin, s)) {
		// for each matching phone number
		for (sregex_iterator it(s.begin(), s.end(), r), end_it;
			       it != end_it; ++it)
			// check whether the number's formatting is valid
			if (valid(*it))
				cout << "valid: " << it->str() << endl;
			else
				cout << "not valid: " << it->str() << endl;
	}

	return 0;
}
#else

// do nothing
int main() { return 0; }

#endif

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cerr;
using std::ostream; using std::cout; using std::endl;

#include <string>
using std::string;

#include <map>
using std::map;

#include <cstddef>
using std::size_t;

#include "Sales_data.h"
#include "debug_rep.h"

// function to end the recursion and print the last element
template<typename T>
ostream &print(ostream &os, const T &t)
{
    return os << t; // no separator after the last element in the pack
}

template <typename T, typename... Args>
ostream &
print(ostream &os, const T &t, const Args&... rest)//expand Args
{
    os << t << ", ";
    return print(os, rest...);                     //expand rest
}

// call debug_rep on each argument in the call to print
template <typename... Args>
ostream &errorMsg(ostream &os, const Args&... rest)
{
	// print(os, debug_rep(a1), debug_rep(a2), ..., debug_rep(an)
	return print(os, debug_rep(rest)...);
}


struct ErrorCode {
	ErrorCode(size_t n = 0): e(n) { }
	size_t e;
	size_t num() const { return e; }
	string lookup() const { return errors[e]; }
	static map<size_t, string> errors;
};

map<size_t, string>
ErrorCode::errors = { {42, "some error"}, { 1024, "another error"} };

int main()
{
	Sales_data item("978-0590353403", 25, 15.99);
	string fcnName("itemProcess");
	ErrorCode code(42);
	string otherData("invalid ISBN");

	errorMsg(cerr, fcnName, code.num(), otherData, "other", item);
	cerr << endl;

	print(cerr, debug_rep(fcnName), debug_rep(code.num()),
	            debug_rep(otherData), debug_rep("otherData"),
	            debug_rep(item));
	cerr << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <initializer_list>
using std::initializer_list;

#include <iostream>
using std::ostream; using std::cout; using std::endl;

#include <algorithm>
using std::min;

#include <string>
using std::string;

#include "Sales_data.h"

// function to end the recursion and print the last element
// this function must be declared before the variadic version of print is defined
template<typename T>
ostream &print(ostream &os, const T &t)
{
	return os << t; // no separator after the last element in the pack
}

// this version of print will be called for all but the last element in the pack

template <typename T, typename... Args>
ostream &print(ostream &os, const T &t, const Args&... rest)
{
	os << t << ", ";           // print the first argument
	return print(os, rest...); // recursive call; print the other arguments
}

template <typename T> bool bigger(const T &t, initializer_list<T> il)
{
	if (il.size() == 0)
		return false;
	auto b = il.begin();
	while (b != il.end())
		if (t < *b)
			return true;
		else
			++b;
	return false;
}

// NB: elements in the list must all have the same type
template <typename T> T min_elem(initializer_list<T> il)
{
	if (il.size() == 0)
		throw "empty";
	auto b = il.begin();      // we know there's at least one element in the list
	T ret(*b++);              // start off with the first element as the ``smallest''
	while (b != il.end())     // till we run out of elements
		ret = min(ret, *b++); // update ret if we find a smaller value
	return ret;               // return the value we found
}

// using variadic templates we can allow for conversions among the elements
// function to end the recursion, called when we have only one element left from the original pack
template<typename T> T min_elem(const T &v)
{
	return v;
}

template <typename T, typename... Back>
T min_elem(T val, Back... back)
{
	// recursive call, "pops" the first element from back, which will be val in this call
	T val2 = min_elem(back...);

	// requires that the types of val2 and val are comparable using <
	return val < val2 ? val : val2;
}

int main()
{
	// no braces, so calls variadic version of min_elem
	cout << min_elem(1.0,2,3,4.5,0.0,5,6,7,8,9) << endl;
	// calls min_element that takes a single argument
	// of type initializer_list<int>
	cout << min_elem({1,2,3,4,0,5,6,7,8,9}) << endl;

	int i = 5;
	cout << bigger(i, {1,2,3,4,0,5,6,7,8,9}) << endl;

	string s = "how now brown cow";
	print(cout, i, s, 42);  // two parameters in the pack
	print(cout, i, s);      // one parameter in the pack
	print(cout, i);         // no parameters in the pack
	cout << endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <vector>
using std::vector;

#include <memory>
using std::shared_ptr; using std::make_shared;

#include "Quote.h"

int main ()
{
	Quote base("0-201-82470-1", 50);
	Bulk_quote bulk("0-201-54848-8", 50, 10, .25);

	// ok: but probably not what is wanted---
	//     the objects in basket have no derived members
	vector<Quote> basket;
	basket.push_back(Quote("0-201-82470-1", 50));

	// ok, but copies only the Quote part of the object into basket
	basket.push_back(Bulk_quote("0-201-54848-8", 50, 10, .25));

	// calls version defined by Quote, prints 750, i.e., 15 * $50
	cout << basket.back().net_price(15) << endl;

	// better approach---store shared_ptrs
	vector<shared_ptr<Quote>> basket2;

	basket2.push_back(make_shared<Quote>("0-201-82470-1", 50));
	basket2.push_back(
		make_shared<Bulk_quote>("0-201-54848-8", 50, 10, .25));

	// calls the version defined by Quote;
	// prints 562.5, i.e., 15 * $50 less the discount
	cout << basket2.back()->net_price(15) << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Vec.h"

#include <string>
using std::string;

#include <iostream>
using std::cin; using std::cout; using std::endl;
using std::istream;

void print(const Vec<string> &svec)
{
	for (auto it : svec)
		cout << it << " " ;
	cout <<endl;
}

Vec<string> getVec(istream &is)
{
	Vec<string> svec;
	string s;
	while (is >> s)
		svec.push_back(s);
	return svec;
}

int main()
{
	Vec<string> svec = getVec(cin);
	print(svec);

	cout << "copy " << svec.size() << endl;
	auto svec2 = svec;
	print(svec2);

	cout << "assign" << endl;
	Vec<string> svec3;
	svec3 = svec2;
	print(svec3);

	Vec<string> v1, v2;
	Vec<string> getVec(istream &);
	v1 = v2;           // copy assignment
	v2 = getVec(cin);  // move assignment

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <vector>
using std::vector;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	// hold the grades we read from the standard input
	vector<unsigned> grades;

	// count the number of grades by clusters of ten:
	// 0--9, 10--19, . ..  90--99, 100
	vector<unsigned> scores(11, 0); // 11 buckets, all initially 0
	unsigned grade;
	while (cin >> grade) {      // read the grades
		if (grade <= 100)       // handle only valid grades
			grades.push_back(grade);
			++scores[grade/10]; // increment the counter for the current cluster
	}
	cout << "grades.size = " << grades.size() << endl;
	for (auto it : grades)
		cout << it << " " ;
	cout << endl;

	cout << "scores.size = " << scores.size() << endl;
	for (auto it : scores)
		cout << it << " " ;
	cout << endl;

	// equivalent program using iterators instead of subscripts
	vector<unsigned> alt_scores(11, 0);  // 11 buckets, all initially 0
	// for each grade in the input
	for (auto it = grades.begin(); it != grades.end(); ++it) {
		unsigned i = *it;
		// increment the counter for the current cluster
		++(*(alt_scores.begin() + i/10));
	}

	cout << "alt_scores.size = " << alt_scores.size() << endl;
	for (auto it = alt_scores.begin(); it != alt_scores.end(); ++it)
		cout << *it << " " ;
	cout << endl;

}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <vector>
using std::vector;

#include <string>
using std::string;

int main()
{
	vector<string> text;     // holds the input

	string s;
	while (getline(cin, s))  // read the entire input file
		text.push_back(s);   // storing each line as an element in text
	cout << "text.size: " << text.size() << endl;

	// print each line in text up to the first blank line
	for (auto it = text.cbegin();
	     it != text.cend() && !(*it).empty(); ++it)
		cout << *it << endl;

	// equivalent loop using arrow to dereference it and call empty
	for (auto it = text.cbegin();
	     it != text.cend() && !it->empty(); ++it)
		cout << *it << endl;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <string>
using std::string;

#include <vector>
using std::vector;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
	vector<int> v = {0,1,2,3,4,5,6,7,8,9};
	auto sz = v.size();
	decltype(sz) i = 0;
	// duplicate contents of v onto the back of v
	while (i != sz) {
		v.push_back(*v.begin() + i);
		++i;
	}
	// prints 0...9 0...9
	for (auto it : v)
		cout << it << " ";
	cout << endl;

	// alternative way to stop when we get to the original last element
	vector<int> alt_v = {0,1,2,3,4,5,6,7,8,9}; // vector with values 0...9
	for (decltype(alt_v.size()) i = 0, sz = alt_v.size(); i != sz; ++i)
		alt_v.push_back(alt_v[i]);

	// prints 0...9 0...9
	for (auto it : alt_v)
		cout << it << " ";
	cout << endl;

	vector<int> v2 = {0,1,2,3,4,5,6,7,8,9}; // vector with values 0 ... 9
	decltype(v2.size()) ix = 0;   // we'll use ix to index the vector

	// set the elements with values less than 5 to 0
	while (ix != v2.size() && v2[ix] < 5) {
		v2[ix] = 0; // changes the value of the element in v
		++ix;       // increment the index so the next iteration fetches the next element
	}

	// print the elements using subscripts
	for (unsigned i = 0; i != v2.size(); ++i)
		cout << v2[i] << " ";
	cout << endl;

	// equivalent but using iterators
	vector<int> alt_v2 = {0,1,2,3,4,5,6,7,8,9}; // vector with values 0...9
	// set the elements to 0 up to the first one that is 5 or greater
	auto it = alt_v2.begin();
	while (it != alt_v2.end() && *it < 5) {
		*it = 0;   // changes the value of the element in alt_v2
		++it;      // advance the iterator to denote the next element
	}
	for (auto it = alt_v2.begin(); // it denotes first element in alt_v2
	          it != alt_v2.end();  // so long as it denotes an element
	          ++it)          // increment the iterator to next element
		cout << *it << " ";  // print element denoted by it from alt_v2
	cout << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

#include <string>
using std::string;

#include <vector>
using std::vector;

#include "Sales_item.h"

int main()
{
	// list initialization, articles has 3 elements
	vector<string> articles = {"a", "an", "the"};

	vector<string> svec; // default initialization; svec has no elements
	vector<int> ivec;             // ivec holds objects of type int
	vector<Sales_item> Sales_vec; // holds Sales_items

	vector<vector<string>> file;  // vector whose elements are vectors
	vector<vector<int>> vecOfvec; // each element is itself a vector

	// all five vectors have size 0
	cout << svec.size() << " " << ivec.size() << " "
	     << Sales_vec.size() << " "
	     << file.size() << " " << vecOfvec.size() << endl;

	vector<int> ivec2(10);     // ten elements, each initialized to 0
	vector<int> ivec3(10, -1); // ten int elements, each initialized to -1
	vector<string> svec2(10);  // ten elements, each an empty string
	vector<string> svec3(10, "hi!"); // ten strings; each element is "hi!"
	cout << ivec2.size() << " " << ivec3.size() << " "
	     << svec2.size() << " " << svec3.size() << endl;

	// 10 is not a string, so cannot be list initialization
	vector<string> v1(10); // construct v1 with ten value-initialized elements
	vector<string> v2{10}; // ten elements value-initialized elements
	vector<string> v3(10, "hi");  // ten elements with value "hi"
	// again list initialization is not viable, so ordinary construction
	vector<string> v4{10, "hi"};  // ten elements with values "hi"

	// all four vectors have size ten
	cout << v1.size() << " " << v2.size()
	     << " " << v3.size() << " " << v4.size() << endl;

	vector<string> vs1{"hi"}; // list initialization: vs1 has 1 element
	vector<string> vs2{10};   // ten default-initialized elements
	vector<string> vs3{10, "hi"}; // has ten elements with value "hi"
	cout << vs1.size() << " " << vs2.size() << " " << vs3.size() << endl;

	vector<int> v5(10, 1);  // ten elements with value 1
	vector<int> v6{10, 1};  // two elements with values 10 and 1
	cout << v5.size() << " " << v6.size() << endl;

	// intention is clearer
	vector<int> alt_v3 = {10};    // one element with value 10
	vector<int> alt_v4 = {10, 1}; // two elements with values 10 and 1
	cout << alt_v3.size() << " " << alt_v4.size() << endl;

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <vector>
using std::vector;

#include <iostream>
using std::cout; using std::endl;

int main()
{

    vector<int> ivec;                // empty vector
    int cnt = 10;
    // add elements 10 . . . 1 to ivec
    while (cnt > 0)
        ivec.push_back(cnt--);       // int postfix decrement

    auto iter = ivec.begin();
    // prints 10 9 8 . . . 1
    while (iter != ivec.end())
        cout << *iter++ << endl; // iterator postfix increment

	vector<int> vec2(10, 0);  // ten elements initially all 0
    cnt = vec2.size();
    // assign values from size . . . 1 to the elements in vec2
    for(vector<int>::size_type ix = 0;
                    ix != vec2.size(); ++ix, --cnt)
        vec2[ix] = cnt;

    iter = vec2.begin();
    // prints 10 9 8 . . . 1
    while (iter != vec2.end())
        cout << *iter++ << endl; // iterator postfix increment

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Animal_virtual_baseVers.h"
#include <iostream>
using std::cout; using std::endl; using std::ostream;

void dance(const Bear&)
	{ cout << "dance(const Bear&)" << endl; }

void rummage(const Raccoon&)
	{ cout << "rummage(const Raccoon&)" << endl; }

ostream& operator<<(ostream&, const ZooAnimal&)
	{ return cout << "ZooAnimal output operator" << endl; }

int main ()
{
	Panda ying_yang;
	dance(ying_yang);   // ok: passes Panda object as a Bear
	rummage(ying_yang); // ok: passes Panda object as a Raccoon

	cout << ying_yang;  // ok: passes Panda object as a ZooAnimal

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

class Base {
public:
    virtual int fcn();
};

int Base::fcn() { cout << "Base::fcn()" << endl; return 0; }

class D1 : public Base {
public:
    // hides fcn in the base; this fcn is not virtual
    // D1 inherits the definition of Base::fcn()
    int fcn(int);      // parameter list differs from fcn in Base
	virtual void f2(); // new virtual function that does not exist in Base
};

int D1::fcn(int) { cout << "D1::fcn(int)" << endl; return 0; }
void D1::f2() { cout << "D1::f2()" << endl; }

class D2 final : public D1 {
public:
    int fcn(int); // nonvirtual function hides D1::fcn(int)
    int fcn();    // overrides virtual fcn from Base
	void f2();    // overrides virtual f2 from D1
};

int D2::fcn(int) { cout << "D2::fcn(int)" << endl; return 0; }
int D2::fcn() { cout << "D2::fcn()" << endl; return 0; }
void D2::f2() { cout << "D2::f2()" << endl; }

int main()
{
    D1 dobj, *dp = &dobj;
    dp->fcn(42); // ok: static call to D1::fcn(int)

    Base bobj;  D1 d1obj; D2 d2obj;

    Base *bp1 = &bobj, *bp2 = &d1obj, *bp3 = &d2obj;
    bp1->fcn(); // virtual call, will call Base::fcn at run time
    bp2->fcn(); // virtual call, will call Base::fcn at run time
    bp3->fcn(); // virtual call, will call D2::fcn at run time

	D1 *d1p = &d1obj; D2 *d2p = &d2obj;
	d1p->f2(); // virtual call, will call D1::f2() at run time
	d2p->f2(); // virtual call, will call D2::f2() at run time
	Base *p1 = &d2obj; D1 *p2 = &d2obj; D2 *p3 =  &d2obj;
	p2->fcn(42);  // statically bound, calls D1::fcn(int)
	p3->fcn(42);  // statically bound, calls D2::fcn(int)

    Base* bp = &d1obj; D1 *dp1 = &d2obj; D2 *dp2 = &d2obj;
    dp1->fcn(10); // static call to D1::fcn(int)
    dp2->fcn(10); // static call to D2::fcn(int)
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
    // initialize counters for each vowel
    unsigned aCnt = 0, eCnt = 0, iCnt = 0, oCnt = 0, uCnt = 0;

    char ch;
    while (cin >> ch) {
    	// if ch is a vowel, increment the appropriate counter
    	switch (ch) {
    		case 'a':
    			++aCnt;
    			break;
    		case 'e':
    			++eCnt;
    			break;
    		case 'i':
    			++iCnt;
    			break;
    		case 'o':
    			++oCnt;
    			break;
    		case 'u':
    			++uCnt;
    			break;
    	}
    }
    // print results
    cout << "Number of vowel a: \t" << aCnt << '\n'
         << "Number of vowel e: \t" << eCnt << '\n'
         << "Number of vowel i: \t" << iCnt << '\n'
         << "Number of vowel o: \t" << oCnt << '\n'
         << "Number of vowel u: \t" << uCnt << endl;

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cout; using std::endl;

int main()
{
	// the compiler might warn about loss of precision
	int ival = 3.541 + 3; // the compiler might warn about loss of precision
	cout << ival << endl;  // prints 6

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <map>
using std::map;

#include <string>
using std::string;

#include <cstddef>
using std::size_t;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
    // count number of times each word occurs in the input
    map<string, size_t> word_count; // empty map from string to size_t
	string word;
	while (cin >> word)
      ++word_count.insert({word, 0}).first->second;

	for(auto it = word_count.cbegin(); it != word_count.cend(); ++it) {
		auto w = *it;
		cout <<  w.first << " occurs " << w.second << " times" << endl;
	}

    // get iterator positioned on the first element
    auto map_it = word_count.cbegin();
    // for each element in the map
    while (map_it != word_count.cend()) {
        // print the element key, value pairs
        cout << map_it->first << " occurs "
             << map_it->second << " times" << endl;
        ++map_it;  // increment iterator to denote the next element
    }

	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <cstddef>
using std::size_t;

#include <cassert>
// assert is a preprocessor macro and therefore not in std
// hence we need to include cassert header,
// but no using declaration for assert

#include <string>
using std::string;

#include <iostream>
using std::endl; using std::cerr; using std::cin;

#include <cstddef>
using std::size_t;

void print(const int ia[], size_t size)
{
#ifndef NDEBUG
// __func__ is a local static defined by the compiler that holds the name of this function
cerr << __func__ << ": array size is " << size << endl;
#endif
// . . .
}

int main()
{
    string word = "foo";
    const string::size_type threshold = 5;
    if (word.size() < threshold)
        cerr << "Error: " << __FILE__
             << " : in function " << __func__
             << " at line " << __LINE__ << endl
             << "       Compiled on " << __DATE__
             << " at " << __TIME__ << endl
             << "       Word read was \"" << word
             << "\":  Length too short" << endl;
    word = "something longer than five chars";
    assert(word.size() > threshold);

    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <memory>
using std::make_shared; using std::weak_ptr; using std::shared_ptr;

int main()
{
	auto p = make_shared<int>(42);

	weak_ptr<int> wp(p);  // wp weakly shares with p; use count in p is unchanged

	p.reset(); // assuming p.unique() was true, the int is deleted

	if (shared_ptr<int> np = wp.lock()) { // true if np is not null
		// inside the if, np shares its object with p
	}
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>

int main()
{
    int sum = 0, val = 1;
    // keep executing the while as long as val is less than or equal to 10
    while (val <= 10) {
        sum += val;  // assigns sum + val to sum
        ++val;       // add 1 to val
    }
    std::cout << "Sum of 1 to 10 inclusive is "
              << sum << std::endl;

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Query.h"
#include "TextQuery.h"
#include <string>
#include <vector>
#include <map>
#include <set>
#include <iostream>
#include <fstream>
#include <cctype>
#include <cstring>

using std::set;
using std::string;
using std::map;
using std::vector;
using std::cerr;
using std::cout;
using std::cin;
using std::ifstream;
using std::endl;

int main(int argc, char **argv)
{
    TextQuery file = get_file(argc, argv);

    // iterate with the user: prompt for a word to find and print results
    do {
        string sought;
        if (!get_word(sought)) break;

        // find all the occurrences of the requested string
        // define synonym for the line_no set
        Query name(sought);
        const auto results = name.eval(file);
        cout << "\nExecuting Query for: " << name << endl;

        // report no matches
        print(cout, results) << endl;
    } while (true);  // loop indefinitely; the exit is inside the loop
    return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <map>
using std::map;

#include <string>
using std::string;

#include <utility>
using std::pair;

#include <cstddef>
using std::size_t;

#include <iostream>
using std::cin; using std::cout; using std::endl;

int main()
{
    // count the number of times each word occurs in the input
    map<string, size_t> word_count; // empty map from string to size_t
    string word;
    while (cin >> word)
      ++word_count[word];

	for (const auto &w : word_count)
		cout <<  w.first << " occurs " << w.second << " times" << endl;

    // get an iterator positioned on the first element
    auto map_it = word_count.cbegin();
    // compare the current iterator to the off-the-end iterator
    while (map_it != word_count.cend()) {
        // dereference the iterator to print the element key--value pairs
        cout << map_it->first << " occurs "
             << map_it->second << " times" << endl;
        ++map_it;  // increment the iterator to denote the next element
    }

	return 0;
}

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <iostream>
using std::cin; using std::cout; using std::endl;

#include <string>
using std::string;

int main()
{
	string word;
	while (cin >> word)       // read until end-of-file
		cout << word << endl; // write each word followed by a new line
	return 0;
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include <map>
#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <stdexcept>
#include <sstream>

using std::map; using std::string; using std::vector;
using std::ifstream; using std::cout; using std::endl;
using std::getline;
using std::runtime_error; using std::istringstream;

map<string, string> buildMap(ifstream &map_file)
{
    map<string, string> trans_map;   // holds the transformations
    string key;    // a word to transform
	string value;  // phrase to use instead
	// read the first word into key and the rest of the line into value
	while (map_file >> key && getline(map_file, value))
		if (value.size() > 1) // check that there is a transformation
        	trans_map[key] = value.substr(1); // skip leading space
		else
			throw runtime_error("no rule for " + key);
	return trans_map;
}

const string &
transform(const string &s, const map<string, string> &m)
{
	// the actual map work; this part is the heart of the program
	auto map_it = m.find(s);
	// if this word is in the transformation map
	if (map_it != m.cend())
		return map_it->second; // use the replacement word
	else
		return s;              // otherwise return the original unchanged
}

// first argument is the transformations file;
// second is file to transform
void word_transform(ifstream &map_file, ifstream &input)
{
	auto trans_map = buildMap(map_file); // store the transformations

	// for debugging purposes print the map after its built
    cout << "Here is our transformation map: \n\n";
	for (auto entry : trans_map)
        cout << "key: "   << entry.first
             << "\tvalue: " << entry.second << endl;
    cout << "\n\n";

	// do the transformation of the given text
    string text;                    // hold each line from the input
    while (getline(input, text)) {  // read a line of input
        istringstream stream(text); // read each word
        string word;
        bool firstword = true;      // controls whether a space is printed
        while (stream >> word) {
           if (firstword)
               firstword = false;
           else
               cout << " ";  // print a space between words
           // transform returns its first argument or its transformation
           cout << transform(word, trans_map); // print the output
        }
        cout << endl;        // done with this line of input
    }
}

int main(int argc, char **argv)
{
	// open and check both files
    if (argc != 3)
        throw runtime_error("wrong number of arguments");

    ifstream map_file(argv[1]); // open transformation file
    if (!map_file)              // check that open succeeded
        throw runtime_error("no transformation file");

    ifstream input(argv[2]);    // open file of text to transform
    if (!input)                 // check that open succeeded
        throw runtime_error("no input file");

	word_transform(map_file, input);

    return 0;  // exiting main will automatically close the files
}
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 *
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 *
 *
 * "The authors and publisher have taken care in the preparation of this book,
 * but make no expressed or implied warranty of any kind and assume no
 * responsibility for errors or omissions. No liability is assumed for
 * incidental or consequential damages in connection with or arising out of the
 * use of the information or programs contained herein."
 *
 * Permission is granted for this code to be used for educational purposes in
 * association with the book, given proper citation if and when posted or
 * reproduced.Any commercial use of this code requires the explicit written
 * permission of the publisher, Addison-Wesley Professional, a division of
 * Pearson Education, Inc. Send your request for permission, stating clearly
 * what code you would like to use, and in what specific way, to the following
 * address:
 *
 * 	Pearson Education, Inc.
 * 	Rights and Permissions Department
 * 	One Lake Street
 * 	Upper Saddle River, NJ  07458
 * 	Fax: (201) 236-3290
*/

#include "Version_test.h"

// if the regular expression library isn't support, do nothing
#ifdef REGEX

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include <regex>
using std::regex; using std::sregex_iterator; using std::smatch;

int main()
{
	string zip = "\\d{5}-\\d{4}|\\d{5}";

	string test_str = "908.647.4306 164 gates, 07933 07933-1257";
	regex r(zip);  // a regex to find the parts in our pattern
	smatch results;

	if (regex_search(test_str, results, r))
		cout << results.str() << endl;

	sregex_iterator it(test_str.begin(), test_str.end(), r);
	sregex_iterator end_it;         // end iterator
	while (it != end_it) {
		cout << it->str() << endl;  // print current match
		++it;                       // advance iterator for next search
	}

	return 0;
}
#else

// do nothing
int main() { return 0; }

#endif

