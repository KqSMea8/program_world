/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 * 
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 * 
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
#ifndef ACCOUNT_H
#define ACCOUNT_H

#include <string>

class Account {
public:
	Account() = default;
	Account(const std::string &s, double amt):
		owner(s), amount(amt) { }

    void calculate() { amount += amount * interestRate; }
    double balance() { return amount; }
public:
    static double rate() { return interestRate; }
    static void rate(double);   
private:
    std::string owner; 
    double amount = 0.0;
    static double interestRate; 
    static double initRate() { return .0225; }
    static const std::string accountType;
    static constexpr int period = 30;// period is a constant expression
    double daily_tbl[period];
};
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
#include <iostream>
#include <algorithm>

class Endangered {
public:
    virtual ~Endangered() 
		{ std::cout << "Endangered dtor" << std::endl; }
    virtual std::ostream& print() const
		{ return std::cout << "Endangered::print" << std::endl; }
    virtual void highlight() const
		{ std::cout << "Endangered::highlight" << std::endl; }
	virtual double max_weight() const
		{ std::cout << "Endangered::max_weight" << std::endl; return 0; }
    // . . .
};

class ZooAnimal;
extern std::ostream&
operator<<(std::ostream&, const ZooAnimal&);

class ZooAnimal {
public:
    ZooAnimal() = default;
    ZooAnimal(std::string animal, bool exhibit,
              std::string family): nm(animal), 
                                   exhibit_stat(exhibit), 
                                   fam_name(family) { } 
    virtual ~ZooAnimal()
		{ std::cout << "Animal dtor" << std::endl; }

    virtual std::ostream& print() const
		{ return std::cout << "Animal::print" << std::endl; }
    virtual int population() const
		{ std::cout << "Animal::population" << std::endl; return 0;}
	virtual double max_weight() const
		{ std::cout << "Animal::max_weight" << std::endl; return 0;}

    // accessors
    std::string name() const { return nm; }
    std::string family_name() const { return fam_name; }
    bool onExhibit() const { return exhibit_stat; }
    // . . .
protected:
    std::string nm;
    bool        exhibit_stat = false;
    std::string fam_name;
    // . . .
private:
};

using DanceType = unsigned;
constexpr DanceType two_left_feet = 0;
constexpr DanceType Astaire = 1;
constexpr DanceType Rogers = 42;

class Bear : public ZooAnimal {
public:
    Bear() = default;
    Bear(std::string name, bool onExhibit=true, 
         std::string family = "Bear"):
                         ZooAnimal(name, onExhibit, family),
                         dancetype(two_left_feet) { }

    virtual std::ostream &print() const
		{ return std::cout << "Bear::print" << std::endl; }
    virtual int toes() const
		{ std::cout << "Bear::toes" << std::endl; return 0; }
    int mumble(int)
		{ std::cout << "Bear::mumble" << std::endl; return 0; }
    void dance(DanceType) const 
		{ std::cout << "Bear::dance" << std::endl; }

    virtual ~Bear()
		{ std::cout << "Bear dtor" << std::endl; }
private:
    DanceType   dancetype = Rogers;
};

class Panda : public Bear, public Endangered {
public:
    Panda() = default;
    Panda(std::string name, bool onExhibit=true);
    virtual ~Panda()
		{ std::cout << "Panda dtor" << std::endl; }
    virtual std::ostream& print() const
		{ return std::cout << "Panda::print" << std::endl; }
    void highlight()
		{ std::cout << "Panda::highlight" << std::endl; }
    virtual int toes()
		{ std::cout << "Panda::toes" << std::endl; return 0; }
    virtual void cuddle()
		{ std::cout << "Panda::cuddle" << std::endl; }
	virtual double max_weight() const;
// . . .
};

inline
Panda::Panda(std::string name, bool onExhibit)
      : Bear(name, onExhibit, "Panda") { }

inline
double Panda::max_weight() const
{
    return std::max(ZooAnimal::max_weight(), 
	                Endangered::max_weight());
}

class PolarBear : public Bear { /* . . . */ };
/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 * 
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 * 
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
#include <iostream>

class Endangered {
public:
    enum Status { critical, environment, improving };
    Endangered(Status stat = improving): animal_status(stat) { }
    virtual ~Endangered() 
		{std::cout << "Endangered::~Endangered" << std::endl; }
    virtual std::ostream& print(std::ostream&) const
		{ return std::cout << "Endangered::print" << std::endl; }
    virtual void highlight() const
		{std::cout << "Endangered::highlighted" << std::endl; }
    // . . .
private:
    Status animal_status;
};

class ZooAnimal;
extern std::ostream&
operator<<(std::ostream&, const ZooAnimal&);

class ZooAnimal {
public:
    ZooAnimal() = default;
    ZooAnimal(std::string animal, bool exhibit,
              std::string family): nm(animal), 
                                   exhibit_stat(exhibit), 
                                   fam_name(family) { } 
    virtual ~ZooAnimal()
		{std::cout << "ZooAnimal::~ZooAnimal" << std::endl; }

    virtual std::ostream& print(std::ostream&) const
		{ return std::cout << "ZooAnimal::print" << std::endl; }
    virtual int population() const
		{std::cout << "ZooAnimal::population" << std::endl;  return 0;}

    // accessors
    std::string name() const { return nm; }
    std::string family_name() const { return fam_name; }
    bool onExhibit() const { return exhibit_stat; }
    // . . .
protected:
    std::string nm;
    bool exhibit_stat = false;
    std::string fam_name;
    // . . .
private:
};

// the order of the keywords public and virtual is not significant
class Raccoon : public virtual ZooAnimal {
public:
    Raccoon() = default;
    Raccoon(std::string name, bool onExhibit=true);

    virtual std::ostream& print(std::ostream&) const
		{ return  std::cout << "Raccoon::print" << std::endl; }

    bool pettable() const {return pettable_flag;  }
    void pettable(bool petval) {pettable_flag = petval;}
    // . . .

protected:
    bool pettable_flag = false;
    // . . .
};

class Bear : virtual public ZooAnimal {
public:
    // when the most derived class
    Bear(std::string name, bool onExhibit=true);
protected:
    // when an intermediate derived class
    Bear() : dance_flag(two_left_feet) { }

public:
    enum DanceType { two_left_feet, macarena, fandango };

    virtual std::ostream &print(std::ostream&) const
		{ return  std::cout << "Bear::print" << std::endl; }
    virtual std::string isA() const
		{ std::cout << "Bear::isA" << std::endl; return "Bear"; }
    int mumble(int)
		{ std::cout << "Bear::mumble" << std::endl; return 0; }
    void dance(DanceType) const
		{ std::cout << "Bear::dance" << std::endl; }

	virtual ~Bear() { std::cout << "Bear::~Bear" << std::endl; }
private:
    std::string name;
    DanceType dance_flag;
};

class Panda : public Bear,
              public Raccoon, public Endangered {
public:
    Panda() = default;
    Panda(std::string name, bool onExhibit=true);
    virtual std::ostream& print(std::ostream&) const
		{ return  std::cout << "Panda::print" << std::endl; }

    bool sleeping() const {return sleeping_flag;}
    void sleeping(bool newval) {sleeping_flag = newval;}
    // . . .

protected:
    bool sleeping_flag = false;
    // . . .
};


Bear::Bear(std::string name, bool onExhibit):
         ZooAnimal(name, onExhibit, "Bear") { }
Raccoon::Raccoon(std::string name, bool onExhibit)
       : ZooAnimal(name, onExhibit, "Raccoon") { }

Panda::Panda(std::string name, bool onExhibit)
      : ZooAnimal(name, onExhibit, "Panda"),
        Bear(name, onExhibit),
        Raccoon(name, onExhibit),
        Endangered(Endangered::critical),
        sleeping_flag(false)   { }

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 * 
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 * 
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

#ifndef BASKET_H
#define BASKET_H

#include <iostream>
#include <string>
#include <set>
#include <map>
#include <utility>
#include <cstddef>
#include <stdexcept>
#include <memory>
#include "Quote.h"

// holds items being purchased
class Basket {
public:
	// Basket uses synthesized default constructor and copy-control members
	void add_item(const std::shared_ptr<Quote> &sale)  
        { items.insert(sale); }

	void add_item(const Quote& sale) // copy the given object
      { items.insert(std::shared_ptr<Quote>(sale.clone())); }

	void add_item(Quote&& sale)      // move the given object
      { items.insert(
	      std::shared_ptr<Quote>(std::move(sale).clone())); }

    // prints the total price for each book 
	// and the overall total for all items in the basket
    double total_receipt(std::ostream&) const;

	// for debugging purposes, prints contents of the basket
	void display (std::ostream&) const;
private:
	// function to compare shared_ptrs needed by the multiset member
	static bool compare(const std::shared_ptr<Quote> &lhs,
	                    const std::shared_ptr<Quote> &rhs)
		{ return lhs->isbn() < rhs->isbn(); }

	// multiset to hold multiple quotes, ordered by the compare member
    std::multiset<std::shared_ptr<Quote>, decltype(compare)*> 
	              items{compare}; 
};

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

#ifndef BLOB_H
#define BLOB_H

#include <iterator>
#include <string>
#include <vector>
#include <initializer_list>
#include <cstddef>
#include <stdexcept>
#include <utility>
#include <memory>
#include <algorithm>
#include <iostream>
#include <cstdlib>
#include <stdexcept>

// forward declarations needed for friend declarations in Blob
template <typename> class BlobPtr;   
template <typename> class Blob; // needed for parameters in operator==
template <typename T> 
    bool operator==(const Blob<T>&, const Blob<T>&);

template <typename T> class Blob {
	// each instantiation of Blob grants access to the version of
	// BlobPtr and the equality operator instantiated with the same type
	friend class BlobPtr<T>;
	friend bool operator==<T>
	       (const Blob<T>&, const Blob<T>&);
public:
	typedef T value_type;
	typedef typename std::vector<T>::size_type size_type;

	// constructors
	Blob(); 
	Blob(std::initializer_list<T> il);
	template <typename It> Blob(It b, It e); 
	Blob(T*, std::size_t);

	// return BlobPtr to the first and one past the last elements
	BlobPtr<T> begin() { return BlobPtr<T>(*this); }
	BlobPtr<T> end() 
	    { auto ret = BlobPtr<T>(*this, data->size()); 
	      return ret; }

	// number of elements in the Blob
	size_type size() const { return data->size(); }
	bool empty() const { return data->empty(); }

	// add and remove elements
	void push_back(const T &t) {data->push_back(t);}
	void push_back(T &&t) { data->push_back(std::move(t)); }
	void pop_back();

	// element access
	T& front();
	T& back();
	T& at(size_type);
	const T& back() const;
	const T& front() const;
	const T& at(size_type) const;
	T& operator[](size_type i); 
	const T& operator[](size_type i) const;

	void swap(Blob &b) { data.swap(b.data); }
private:
	std::shared_ptr<std::vector<T>> data; 

	// throws msg if data[i] isn't valid
	void check(size_type i, const std::string &msg) const;
};

// constructors
template <typename T>
Blob<T>::Blob(T *p, std::size_t n): 
              data(std::make_shared<std::vector<T>>(p, p + n)) { }

template <typename T>
Blob<T>::Blob():
	          data(std::make_shared<std::vector<T>>()) { }

template <typename T>     // type parameter for the class
template <typename It>    // type parameter for the constructor
    Blob<T>::Blob(It b, It e):
              data(std::make_shared<std::vector<T>>(b, e)) { }

template <typename T>
Blob<T>::Blob(std::initializer_list<T> il): 
              data(std::make_shared<std::vector<T>>(il)) { }

// check member
template <typename T>
void Blob<T>::check(size_type i, const std::string &msg) const
{
	if (i >= data->size())
		throw std::out_of_range(msg);
}

// element access members
template <typename T>
T& Blob<T>::front()
{
	// if the vector is empty, check will throw
	check(0, "front on empty Blob");
	return data->front();
}

template <typename T>
T& Blob<T>::back() 
{
	check(0, "back on empty Blob");
	return data->back();
}

template <typename T> void Blob<T>::pop_back() 
{
	check(0, "pop_back on empty Blob"); 
	data->pop_back(); 
}

template <typename T>
const T& Blob<T>::front() const 
{
	check(0, "front on empty Blob");
	return data->front();
}

template <typename T>
const T& Blob<T>::back() const 
{
	check(0, "back on empty Blob");
	return data->back();
}

template <typename T>
T& Blob<T>::at(size_type i) 
{
	// if i is too big, check will throw, preventing access to a nonexistent element
	check(i, "subscript out of range");
	return (*data)[i];  // (*data) is the vector to which this object points
}

template <typename T>
const T&
Blob<T>::at(size_type i) const
{
	check(i, "subscript out of range");
	return (*data)[i];
}

template <typename T>
T& Blob<T>::operator[](size_type i)
{
	// if i is too big, check will throw, preventing access to a nonexistent element
	check(i, "subscript out of range");
	return (*data)[i];
}

template <typename T>
const T& 
Blob<T>::operator[](size_type i) const
{
	check(i, "subscript out of range");
	return (*data)[i];
}

// operators
template <typename T>
std::ostream&
operator<<(std::ostream &os, const Blob<T> a)
{
	os << "< ";
	for (size_t i = 0; i < a.size(); ++i) 
		os << a[i] << " ";
	os << " >";
	return os;
}

template <typename T>
bool
operator==(const Blob<T> lhs, const Blob<T> rhs)
{
	if (rhs.size() != lhs.size())
		return false;
	for (size_t i = 0; i < lhs.size(); ++i) {
		if (lhs[i] != rhs[i])
			return false;
	}
	return true;
}

// BlobPtr throws an exception on attempts to access a nonexistent element 
template <typename T>
bool operator==(const BlobPtr<T>&, const BlobPtr<T>&);

template <typename T> class BlobPtr : public std::iterator<std::bidirectional_iterator_tag,T> {
	friend bool 
	operator==<T>(const BlobPtr<T>&, const BlobPtr<T>&);
public:
    BlobPtr(): curr(0) { }
    BlobPtr(Blob<T> &a, size_t sz = 0): 
	        wptr(a.data), curr(sz) { }

	T &operator[](std::size_t i)
	{ auto p = check(i, "subscript out of range"); 
	  return (*p)[i];  // (*p) is the vector to which this object points
	}

	const T &operator[](std::size_t i) const
	{ auto p = check(i, "subscript out of range"); 
	  return (*p)[i];  // (*p) is the vector to which this object points
	}
    
    T& operator*() const
	{ auto p = check(curr, "dereference past end"); 
	  return (*p)[curr];  // (*p) is the vector to which this object points
	}
    T* operator->() const
	{ // delegate the real work to the dereference operator
	 return & this->operator*(); 
	}

    // increment and decrement
    BlobPtr& operator++();       // prefix operators
    BlobPtr& operator--();

    BlobPtr operator++(int);     // postfix operators
    BlobPtr operator--(int);
    
private:
	// check returns a shared_ptr to the vector if the check succeeds
	std::shared_ptr<std::vector<T>> 
		check(std::size_t, const std::string&) const;

	// store a weak_ptr, which means the underlying vector might be destroyed
    std::weak_ptr<std::vector<T>> wptr;  
    std::size_t curr;      // current position within the array
};

// equality operators
template <typename T>
bool operator==(const BlobPtr<T> &lhs, const BlobPtr<T> &rhs)
{
	return lhs.wptr.lock().get() == rhs.wptr.lock().get() && 
	       lhs.curr == rhs.curr;
}

template <typename T>
bool operator!=(const BlobPtr<T> &lhs, const BlobPtr<T> &rhs)
{
	return !(lhs == rhs);
}

// check member
template <typename T>
std::shared_ptr<std::vector<T>> 
BlobPtr<T>::check(std::size_t i, const std::string &msg) const
{
	auto ret = wptr.lock();   // is the vector still around?
	if (!ret)
		throw std::runtime_error("unbound BlobPtr");
	if (i >= ret->size()) 
		throw std::out_of_range(msg);
	return ret; // otherwise, return a shared_ptr to the vector
}

// member operators
// postfix: increment/decrement the object but return the unchanged value
template <typename T>
BlobPtr<T> BlobPtr<T>::operator++(int)
{
    // no check needed here; the call to prefix increment will do the check
    BlobPtr ret = *this;   // save the current value
    ++*this;     // advance one element; prefix ++ checks the increment
    return ret;  // return the saved state
}

template <typename T>
BlobPtr<T> BlobPtr<T>::operator--(int)
{
    // no check needed here; the call to prefix decrement will do the check
    BlobPtr ret = *this;  // save the current value
	--*this;     // move backward one element; prefix -- checks the decrement
    return ret;  // return the saved state
}

// prefix: return a reference to the incremented/decremented object
template <typename T>
BlobPtr<T>& BlobPtr<T>::operator++()
{
	// if curr already points past the end of the container, can't increment it
	check(curr, "increment past end of BlobPtr");
    ++curr;       // advance the current state
    return *this;
}

template <typename T>
BlobPtr<T>& BlobPtr<T>::operator--()
{
	// if curr is zero, decrementing it will yield an invalid subscript
    --curr;       // move the current state back one element
    check(-1, "decrement past begin of BlobPtr");
    return *this;
}
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

#ifndef BOOKEXCEPT_H
#define BOOKEXCEPT_H
#include <stdexcept>
#include <string>

// hypothetical exception classes for a bookstore application
class out_of_stock: public std::runtime_error {
public:
    explicit out_of_stock(const std::string &s):
                       std::runtime_error(s) { }
};

class isbn_mismatch: public std::logic_error {
public:
    explicit isbn_mismatch(const std::string &s): 
                          std::logic_error(s) { }
    isbn_mismatch(const std::string &s,
        const std::string &lhs, const std::string &rhs):
        std::logic_error(s), left(lhs), right(rhs) { }
    const std::string left, right;
};

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

#ifndef COMPARE_H
#define COMPARE_H
#include <cstring>

// implement strcmp-like generic compare function 
// returns 0 if the values are equal, 1 if v1 is larger, -1 if v1 is smaller
template <typename T>
int compare(const T &v1, const T &v2)
{
    if (v1 < v2) return -1;
    if (v2 < v1) return 1;
    return 0;
}

// special version of compare to handle C-style character strings
template <>
inline
int compare(const char* const &v1, const char* const &v2)
{
    return std::strcmp(v1, v2);
}

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

#ifndef DEBUG_H
#define DEBUG_H
class Debug {
public:
	constexpr Debug(bool b = true): hw(b), io(b), other(b) { }
	constexpr Debug(bool h, bool i, bool o): 
	                                hw(h), io(i), other(o) { }
	constexpr bool any() { return hw || io || other; }
	constexpr bool hardware() { return hw || io; }
	constexpr bool app() { return other; }

	void set_io(bool b) { io = b; }
	void set_hw(bool b) { hw = b; }
	void set_other(bool b) { hw = b; }
private:
	bool hw;    // hardware errors other than IO errors
	bool io;    // IO errors
	bool other; // other errors
};

class HW_Subsystem {
public:
	HW_Subsystem(): debug(false) { }          // by default no debugging
	bool field_debug()   { return debug.any(); }
	bool default_debug() { return enable.any() && debug.any(); }
	void set_debug(bool b) { debug.set_hw(b); }  // turn on hardware debugging
private:
	Debug debug;
	constexpr static Debug enable{true, false, false};
};

class IO_Subsystem {
public:
	IO_Subsystem(): debug(false) { }          // by default no debugging
	bool field_debug()     { return debug.any(); }
	bool default_debug()   { return enable.any() && debug.any(); }
	void set_debug(bool b) { debug.set_io(b); }  // turn on IO debugging
private:
	Debug debug;
	constexpr static Debug enable{true, false, true};
};
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

#ifndef DEBUGDELETE_H
#define DEBUGDELETE_H

#include <cstddef>
#include <iostream>
#include <string>

// function-object class that calls delete on a given pointer
class DebugDelete {
public:
	DebugDelete(const std::string &s = "unique_ptr",
                std::ostream &strm = std::cerr): os(strm), type(s) { }
	// as with any function template, the type of T is deduced by the compiler
	template <typename T> void operator()(T *p) const 
	  { os << "deleting " << type << std::endl; delete p; }
private:
	std::ostream &os;  // where to print debugging info
	std::string type;  // what type of smart pointer we're deleting
};

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

#ifndef DEBUG_REP_H
#define DEBUG_REP_H
#include <iostream>
#include <string>
#include <vector>
#include <sstream>

/* this file uses two preprocessor variables to control whether
 * we use nontemplate functions or specializations for string
 * data and to control whether we define versions of debug_rep
 * that handle character pointers.
 *
 * SPECIALIZED is defined, then we define specializations
 *             for string, char*, and const char* and do not
 *             define nontemplate functions taking these types
 *
 * OVERCHAR only matters if SPECIALIZED is not defined.  In this case
 *          if OVERCHAR is defined, we define one nontemplate function
 *          that takes a string; if OVERCHAR is not defined 
 *          we also define nontemplate functions taking char* and
 *          const char*
*/
#ifndef SPECIALIZED
std::string debug_rep(const std::string &s);
#ifndef OVERCHAR
std::string debug_rep(char *p);
std::string debug_rep(const char *cp);
#endif
#endif
// overloaded, not specialized, function templates
template <typename T> std::string debug_rep(const T &t);
template <typename T> std::string debug_rep(T *p);
template <typename T> std::string debug_rep(T b, T e);
template <typename T> std::string debug_rep(const std::vector<T> &v);

#ifdef SPECIALIZED
// specialized versions to handle strings and character pointers
// declarations for specializations should follow declarations for all overloaded templates
template <> std::string debug_rep(const std::string&); 
template <> std::string debug_rep(const char*);
template <> std::string debug_rep(char*);
#endif

// print any type we don't otherwise handle
template <typename T> std::string debug_rep(const T &t)
{
#ifdef DEBUG
	std::cout << "const T&" << "\t";
#endif
	std::ostringstream ret; 
	ret << t; // uses T's output operator to print a representation of t
	return ret.str();  // return a copy of the string to which ret is bound
}

// print pointers as their pointer value 
// followed by the object to which the pointer points
// NB: this function will not work properly with char*
template <typename T> std::string debug_rep(T *p)
{
#ifdef DEBUG
	std::cout << "T*" << "\t";
#endif
	std::ostringstream ret;
	ret << "pointer: " << p;         // print the pointer's own value
	if (p)
		ret << " " << debug_rep(*p); // print the value to which p points
	else
		ret << " null pointer";      // or indicate that the p is null
	return ret.str(); // return a copy of the string to which ret is bound
}
#ifndef SPECIALIZED
// print strings inside double quotes 
std::string debug_rep(const std::string &s)
#else
template <> std::string debug_rep(const std::string &s)
#endif
{
#ifdef DEBUG
	std::cout << "const string &" << "\t";
#endif
	return '"' + s + '"';
}


#ifndef OVERCHAR
// convert the character pointers to string and call the string version of debug_rep
std::string debug_rep(char *p) 
{
	return debug_rep(std::string(p));
}
std::string debug_rep(const char *p) 
{
	return debug_rep(std::string(p));
}
#endif
#ifdef SPECIALIZED
template<> std::string debug_rep(char *p)
	{ return debug_rep(std::string(p)); }
template <> std::string debug_rep(const char *cp)
	{ return debug_rep(std::string(cp)); }
#endif

template <typename T> std::string debug_rep(T b, T e)
{
	std::ostringstream ret;
	for (T it = b; it != e; ++it) {
		if (it != b)
			ret << ",";            // put comma before all but the first element
		ret << debug_rep(*it);     // print the element
	}
	return ret.str();
}

template <typename T> std::string debug_rep(const std::vector<T> &v)
{
	std::ostringstream ret;
	ret << "vector: [";
	ret << debug_rep(v.begin(), v.end());
	ret << "]";
	return ret.str();
}
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

#ifndef FOLDER_H
#define FOLDER_H

#include <string>
#include <set>

class Folder;

class Message {
	friend void swap(Message&, Message&);
	friend class Folder;
public:
    // folders is implicitly initialized to the empty set 
    explicit Message(const std::string &str = ""): 
		contents(str) { }  

    // copy control to manage pointers to this Message
    Message(const Message&);             // copy constructor
    Message& operator=(const Message&);  // copy assignment
    ~Message();                          // destructor
    Message(Message&&);            // move constructor
    Message& operator=(Message&&); // move assignment

    // add/remove this Message from the specified Folder's set of messages
    void save(Folder&);   
    void remove(Folder&); 
    void debug_print(); // print contents and it's list of Folders, 
                        // printing each Folder as well
private:
    std::string contents;      // actual message text
    std::set<Folder*> folders; // Folders that have this Message

    // utility functions used by copy constructor, assignment, and destructor
    // add this Message to the Folders that point to the parameter
    void add_to_Folders(const Message&);
	void move_Folders(Message*);
    // remove this Message from every Folder in folders
    void remove_from_Folders(); 

    // used by Folder class to add self to this Message's set of Folder's
    void addFldr(Folder *f) { folders.insert(f); }
    void remFldr(Folder *f) { folders.erase(f); }
};
// declaration for swap should be in the same header as Message itself
void swap(Message&, Message&);

class Folder {
	friend void swap(Message&, Message&);
	friend class Message;
public:
    ~Folder(); // remove self from Messages in msgs
    Folder(const Folder&); // add new folder to each Message in msgs
    Folder& operator=(const Folder&); // delete Folder from lhs messages
                                      // add Folder to rhs messages
    Folder(Folder&&);   // move Messages to this Folder 
    Folder& operator=(Folder&&); // delete Folder from lhs messages
                                 // add Folder to rhs messages

    Folder() = default; // defaults ok

    void save(Message&);   // add this message to folder
    void remove(Message&); // remove this message from this folder
    
    void debug_print(); // print contents and it's list of Folders, 
private:
    std::set<Message*> msgs;  // messages in this folder

    void add_to_Messages(const Folder&);// add this Folder to each Message
    void remove_from_Msgs();     // remove this Folder from each Message
    void addMsg(Message *m) { msgs.insert(m); }
    void remMsg(Message *m) { msgs.erase(m); }
	void move_Messages(Folder*); // move Message pointers to point to this Folder
};

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

#ifndef FOO_H
#define FOO_H

#include <iostream>

typedef int T;
struct Foo {  // members are public by default
	Foo(T t): val(t) { }
	T val;
};

std::ostream&
print(std::ostream &os, const Foo &f) 
{
	os << f.val;
	return os;
}

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

// not included in book text, but used by programs in this directory
#ifndef LOCALMATH_H
#define LOCALMATH_H

//definition in LocalMath.cc
int fact(int);        // iterative definition of factorial
int factorial(int);   // recrusive version of factorial
int gcd(int, int);    // find greatest common divisor
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

#include <cstddef>
using std::size_t;

#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#ifndef MAKE_PLURAL_H
#define MAKE_PLURAL_H

// return the plural version of word if ctr is greater than 1
inline
string make_plural(size_t ctr, const string &word, 
                               const string &ending)
{
	return (ctr > 1) ? word + ending : word;
}

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

#ifndef PRINTFCNS_H
#define PRINTFCNS_H
#include <vector>
void print(const char *cp);
void print(const int *beg, const int *end); 
void print(std::vector<int>::const_iterator beg,
           std::vector<int>::const_iterator end);
void print(const int ia[], size_t size);
void print(const std::vector<int>&);

inline foo() {
int j[2] = {0,1};
print("Hello World");        // calls print(const char*)
print(j, end(j) - begin(j)); // calls print(const int*, size_t)
print(begin(j), end(j));     // calls print(const int*, const int*)
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

#ifndef QUERY_H
#define QUERY_H
#include "TextQuery.h"
#include <string>
#include <set>
#include <iostream>
#include <fstream>
#include <sstream>
#include <memory>

// abstract class acts as a base class for concrete query types; all members are private
class Query_base {
    friend class Query;  
protected:
    using line_no = TextQuery::line_no; // used in the eval functions
    virtual ~Query_base() = default;
private:
    // eval returns the QueryResult that matches this Query
    virtual QueryResult eval(const TextQuery&) const = 0; 
    // rep is a string representation of the query
	virtual std::string rep() const = 0;
};

// interface class to manage the Query_base inheritance hierarchy
class Query {
    // these operators need access to the shared_ptr constructor
    friend Query operator~(const Query &);
    friend Query operator|(const Query&, const Query&);
    friend Query operator&(const Query&, const Query&);
public:
    Query(const std::string&);  // builds a new WordQuery

    // interface functions: call the corresponding Query_base operations
    QueryResult eval(const TextQuery &t) const 
                            { return q->eval(t); }
	std::string rep() const { return q->rep(); }
private:
    Query(std::shared_ptr<Query_base> query): q(query) { }
    std::shared_ptr<Query_base> q;
};
inline 
std::ostream &
operator<<(std::ostream &os, const Query &query) 
{
	// Query::rep makes a virtual call through its Query_base pointer to rep() 
	return os << query.rep(); 
}

class WordQuery: public Query_base {
    friend class Query; // Query uses the WordQuery constructor
    WordQuery(const std::string &s): query_word(s) { }

    // concrete class: WordQuery defines all inherited pure virtual functions
    QueryResult eval(const TextQuery &t) const
                     { return t.query(query_word); }
	std::string rep() const { return query_word; }
    std::string query_word;   // word for which to search 
};

inline
Query::Query(const std::string &s): q(new WordQuery(s)) { }

class NotQuery: public Query_base {
    friend Query operator~(const Query &);
    NotQuery(const Query &q): query(q) { }

    // concrete class: NotQuery defines all inherited pure virtual functions
	std::string rep() const {return "~(" + query.rep() + ")";}
    QueryResult eval(const TextQuery&) const;
    Query query;
};

class BinaryQuery: public Query_base {
protected:
    BinaryQuery(const Query &l, const Query &r, std::string s): 
          lhs(l), rhs(r), opSym(s) { }

    // abstract class: BinaryQuery doesn't define eval 
	std::string rep() const { return "(" + lhs.rep() + " " 
	                                     + opSym + " " 
		                                 + rhs.rep() + ")"; }

    Query lhs, rhs;    // right- and left-hand operands
    std::string opSym; // name of the operator
};
    
class AndQuery: public BinaryQuery {
    friend Query operator&(const Query&, const Query&);
    AndQuery(const Query &left, const Query &right): 
                        BinaryQuery(left, right, "&") { }

    // concrete class: AndQuery inherits rep and defines the remaining pure virtual
    QueryResult eval(const TextQuery&) const;
};

class OrQuery: public BinaryQuery {
    friend Query operator|(const Query&, const Query&);
    OrQuery(const Query &left, const Query &right): 
                BinaryQuery(left, right, "|") { }

    QueryResult eval(const TextQuery&) const;
};

inline Query operator&(const Query &lhs, const Query &rhs)
{
    return std::shared_ptr<Query_base>(new AndQuery(lhs, rhs));
}

inline Query operator|(const Query &lhs, const Query &rhs)
{
    return std::shared_ptr<Query_base>(new OrQuery(lhs, rhs));
}

inline Query operator~(const Query &operand)
{
    return std::shared_ptr<Query_base>(new NotQuery(operand));
}

std::ifstream& open_file(std::ifstream&, const std::string&);
TextQuery get_file(int, char**);
bool get_word(std::string&);
bool get_words(std::string&, std::string&);
std::ostream &print(std::ostream&, const QueryResult&);

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

#ifndef QUERYRESULT_H
#define QUERYRESULT_H
#include <memory>
#include <string>
#include <vector>
#include <set>
#include <iostream>

class QueryResult {
friend std::ostream& print(std::ostream&, const QueryResult&);
public:
	typedef std::vector<std::string>::size_type line_no;
	typedef std::set<line_no>::const_iterator line_it;
	QueryResult(std::string s, 
	            std::shared_ptr<std::set<line_no>> p, 
	            std::shared_ptr<std::vector<std::string>> f):
		sought(s), lines(p), file(f) { }
	std::set<line_no>::size_type size() const  { return lines->size(); }
	line_it begin() const { return lines->cbegin(); }
	line_it end() const   { return lines->cend(); }
	std::shared_ptr<std::vector<std::string>> get_file() { return file; }
private:
	std::string sought;  // word this query represents
	std::shared_ptr<std::set<line_no>> lines; // lines it's on
	std::shared_ptr<std::vector<std::string>> file;  //input file
};

std::ostream &print(std::ostream&, const QueryResult&);
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

#ifndef QUOTE_H
#define QUOTE_H

#include "Version_test.h"

#include <memory>
#include <iostream>
#include <string>
#include <cstddef>

// Item sold at an undiscounted price
// derived classes will define various discount strategies
class Quote {
friend std::istream& operator>>(std::istream&, Quote&);
friend std::ostream& operator<<(std::ostream&, const Quote&);
public:
	Quote() = default;  
    Quote(const std::string &book, double sales_price):
                     bookNo(book), price(sales_price) { }

    // virtual destructor needed 
	// if a base pointer pointing to a derived object is deleted
    virtual ~Quote() = default; // dynamic binding for the destructor

    std::string isbn() const { return bookNo; }

    // returns the total sales price for the specified number of items
    // derived classes will override and apply different discount algorithms
    virtual double net_price(std::size_t n) const 
               { return n * price; }

	// virtual function to return a dynamically allocated copy of itself

#ifdef REFMEMS
    virtual Quote* clone() const & {return new Quote(*this);}
    virtual Quote* clone() && {return new Quote(std::move(*this));}
#else
	// without reference qualification on member functions
	// we can't overloaded on rvalue reference and const lvalue reference
	// so for now we just implement a single version that copies itself
    virtual Quote* clone() const {return new Quote(*this);}
#endif
private:
    std::string bookNo; // ISBN number of this item
protected:
    double price = 0.0; // normal, undiscounted price
};

// abstract base class to hold the discount rate and quantity
// derived classes will implement pricing strategies using these data
class Disc_quote : public Quote {
public:
    // other members as before
    Disc_quote() = default;
    Disc_quote(const std::string& book, double price,
              std::size_t qty, double disc):
                 Quote(book, price),
                 quantity(qty), discount(disc) { }

    double net_price(std::size_t) const = 0;

    std::pair<size_t, double> discount_policy() const
        { return {quantity, discount}; }
protected:
    std::size_t quantity = 0; // purchase size for the discount to apply
    double discount = 0.0;    // fractional discount to apply
};

// the discount kicks in when a specified number of copies of the same book are sold
// the discount is expressed as a fraction used to reduce the normal price

class Bulk_quote : public Disc_quote { // Bulk_quote inherits from Quote
public:
    Bulk_quote() = default;  
    Bulk_quote(const std::string& book, double p, 
	           std::size_t qty, double disc) :
               Disc_quote(book, p, qty, disc) { }

    // overrides the base version in order to implement the bulk purchase discount policy
    double net_price(std::size_t) const override;

#ifdef REFMEMS
    Bulk_quote* clone() const & {return new Bulk_quote(*this);}
    Bulk_quote* clone() && {return new Bulk_quote(std::move(*this));}
#else
    Bulk_quote* clone() const {return new Bulk_quote(*this);}
#endif
};

// discount (a fraction off list) for only a specified number of copies, 
// additional copies sold at standard price
class Lim_quote : public Disc_quote {
public:
    Lim_quote(const std::string& book = "", 
             double sales_price = 0.0,
             std::size_t qty = 0, double disc_rate = 0.0):
                 Disc_quote(book, sales_price, qty, disc_rate) { }

    // overrides base version so as to implement limited discount policy
    double net_price(std::size_t) const;

#ifdef REFMEMS
    Lim_quote* clone() const & { return new Lim_quote(*this); }
    Lim_quote* clone() && { return new Lim_quote(std::move(*this)); }
#else
    Lim_quote* clone() const { return new Lim_quote(*this); }
#endif
};

double print_total(std::ostream &, const Quote&, std::size_t);

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

#ifndef SALES_DATA_H
#define SALES_DATA_H

#include <string>
#include <iostream>

class Sales_data {
friend Sales_data add(const Sales_data&, const Sales_data&);
friend std::ostream &print(std::ostream&, const Sales_data&);
friend std::istream &read(std::istream&, Sales_data&);
public:
	// constructors
	Sales_data() = default;
	Sales_data(const std::string &s): bookNo(s) { }
	Sales_data(const std::string &s, unsigned n, double p):
	           bookNo(s), units_sold(n), revenue(p*n) { }
	Sales_data(std::istream &);

	// operations on Sales_data objects
	std::string isbn() const { return bookNo; }
	Sales_data& combine(const Sales_data&);
	double avg_price() const;
private:
	std::string bookNo;
	unsigned units_sold = 0;
	double revenue = 0.0;
};


// nonmember Sales_data interface functions
Sales_data add(const Sales_data&, const Sales_data&);
std::ostream &print(std::ostream&, const Sales_data&);
std::istream &read(std::istream&, Sales_data&);

// used in future chapters
inline 
bool compareIsbn(const Sales_data &lhs, const Sales_data &rhs)
{
	return lhs.isbn() < rhs.isbn();
}
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

#ifndef SALES_DATA_H
#define SALES_DATA_H

#include <string>
#include <iostream>

class Sales_data {
friend std::ostream &operator<<
                         (std::ostream&, const Sales_data&);
friend std::istream &operator>>(std::istream&, Sales_data&);
friend bool operator==(const Sales_data &, const Sales_data &);

friend std::ostream &print(std::ostream&, const Sales_data&);
friend std::istream &read(std::istream&, Sales_data&);

public:
	// constructors
	Sales_data() = default;
	Sales_data(const std::string &s): bookNo(s) { }
	Sales_data(const std::string &s, unsigned n, double p):
	           bookNo(s), units_sold(n), revenue(p*n) { }
	Sales_data(std::istream &);

	std::string isbn() const { return bookNo; }
	Sales_data& operator+=(const Sales_data&);
private:
	double avg_price() const;  
	std::string bookNo;
	unsigned units_sold = 0;
	double revenue = 0.0;
};

// non-member Sales_data operations
inline
bool compareIsbn(const Sales_data &lhs, const Sales_data &rhs)
{ return lhs.isbn() < rhs.isbn(); }

inline
bool operator==(const Sales_data &lhs, const Sales_data &rhs)
{
	return lhs.isbn() == rhs.isbn() && 
	       lhs.units_sold == rhs.units_sold && 
	       lhs.revenue == rhs.revenue;
}
inline
bool operator!=(const Sales_data &lhs, const Sales_data &rhs)
{
	return !(lhs == rhs);
}

// old versions
Sales_data add(const Sales_data&, const Sales_data&);
std::ostream &print(std::ostream&, const Sales_data&);
std::istream &read(std::istream&, Sales_data&);

// new operator functions
Sales_data operator+(const Sales_data&, const Sales_data&);
std::ostream &operator<<(std::ostream&, const Sales_data&);
std::istream &operator>>(std::istream&, Sales_data&);
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

#ifndef SALES_DATA_H
#define SALES_DATA_H

#include <string>
#include <iostream>

// unchanged from chapter 14 except for added friend declaration for hash
class Sales_data {
friend class std::hash<Sales_data>;
friend std::ostream &operator<<
                         (std::ostream&, const Sales_data&);
friend std::istream &operator>>(std::istream&, Sales_data&);
friend bool operator==(const Sales_data &, const Sales_data &);

friend std::ostream &print(std::ostream&, const Sales_data&);
friend std::istream &read(std::istream&, Sales_data&);
public:
	// constructors
	Sales_data() = default;
	Sales_data(const std::string &s): bookNo(s) { }
	Sales_data(const std::string &s, unsigned n, double p):
	           bookNo(s), units_sold(n), revenue(p*n) { }
	Sales_data(std::istream &);
	std::string isbn() const { return bookNo; }
	Sales_data& operator+=(const Sales_data&);
private:
	double avg_price() const;  
	std::string bookNo;
	unsigned units_sold = 0;
	double revenue = 0.0;
};

namespace std {
template <>              // we're defining a specialization with
struct hash<Sales_data>  // the template parameter of Sales_data
{
    // the type used to hash an unordered container must define these types
    typedef size_t result_type;
    typedef Sales_data argument_type; // by default, this type needs ==

    size_t operator()(const Sales_data& s) const;

    // our class uses synthesized copy control and default constructor
    // other members as before
};
}  // close the std namespace; note: no semicolon after the close curly

// non-member Sales_data operations
inline
bool compareIsbn(const Sales_data &lhs, const Sales_data &rhs)
{ return lhs.isbn() < rhs.isbn(); }

inline
bool operator==(const Sales_data &lhs, const Sales_data &rhs)
{
	return lhs.isbn() == rhs.isbn() && 
	       lhs.units_sold == rhs.units_sold && 
	       lhs.revenue == rhs.revenue;
}
inline
bool operator!=(const Sales_data &lhs, const Sales_data &rhs)
{
	return !(lhs == rhs);
}

Sales_data add(const Sales_data&, const Sales_data&);
std::ostream &print(std::ostream&, const Sales_data&);
std::istream &read(std::istream&, Sales_data&);
Sales_data operator+(const Sales_data&, const Sales_data&);
std::ostream &operator<<(std::ostream&, const Sales_data&);
std::istream &operator>>(std::istream&, Sales_data&);
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

#ifndef SALES_DATA_H
#define SALES_DATA_H

#include <string>

struct Sales_data {
	std::string bookNo;
	unsigned units_sold = 0;
	double revenue = 0.0;
};
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
 *     Pearson Education, Inc.
 *     Rights and Permissions Department
 *     One Lake Street
 *     Upper Saddle River, NJ  07458
 *     Fax: (201) 236-3290
*/ 

/* This file defines the Sales_item class used in chapter 1.
 * The code used in this file will be explained in
 * Chapter 7 (Classes) and Chapter 14 (Overloaded Operators)
 * Readers shouldn't try to understand the code in this file
 * until they have read those chapters.
*/

#ifndef SALESITEM_H
// we're here only if SALESITEM_H has not yet been defined 
#define SALESITEM_H

// Definition of Sales_item class and related functions goes here
#include <iostream>
#include <string>

class Sales_item {
// these declarations are explained section 7.2.1, p. 270 
// and in chapter 14, pages 557, 558, 561
friend std::istream& operator>>(std::istream&, Sales_item&);
friend std::ostream& operator<<(std::ostream&, const Sales_item&);
friend bool operator<(const Sales_item&, const Sales_item&);
friend bool 
operator==(const Sales_item&, const Sales_item&);
public:
    // constructors are explained in section 7.1.4, pages 262 - 265
    // default constructor needed to initialize members of built-in type
    Sales_item() = default;
    Sales_item(const std::string &book): bookNo(book) { }
    Sales_item(std::istream &is) { is >> *this; }
public:
    // operations on Sales_item objects
    // member binary operator: left-hand operand bound to implicit this pointer
    Sales_item& operator+=(const Sales_item&);
    
    // operations on Sales_item objects
    std::string isbn() const { return bookNo; }
    double avg_price() const;
// private members as before
private:
    std::string bookNo;      // implicitly initialized to the empty string
    unsigned units_sold = 0; // explicitly initialized
    double revenue = 0.0;
};

// used in chapter 10
inline
bool compareIsbn(const Sales_item &lhs, const Sales_item &rhs) 
{ return lhs.isbn() == rhs.isbn(); }

// nonmember binary operator: must declare a parameter for each operand
Sales_item operator+(const Sales_item&, const Sales_item&);

inline bool 
operator==(const Sales_item &lhs, const Sales_item &rhs)
{
    // must be made a friend of Sales_item
    return lhs.units_sold == rhs.units_sold &&
           lhs.revenue == rhs.revenue &&
           lhs.isbn() == rhs.isbn();
}

inline bool 
operator!=(const Sales_item &lhs, const Sales_item &rhs)
{
    return !(lhs == rhs); // != defined in terms of operator==
}

// assumes that both objects refer to the same ISBN
Sales_item& Sales_item::operator+=(const Sales_item& rhs) 
{
    units_sold += rhs.units_sold; 
    revenue += rhs.revenue; 
    return *this;
}

// assumes that both objects refer to the same ISBN
Sales_item 
operator+(const Sales_item& lhs, const Sales_item& rhs) 
{
    Sales_item ret(lhs);  // copy (|lhs|) into a local object that we'll return
    ret += rhs;           // add in the contents of (|rhs|) 
    return ret;           // return (|ret|) by value
}

std::istream& 
operator>>(std::istream& in, Sales_item& s)
{
    double price;
    in >> s.bookNo >> s.units_sold >> price;
    // check that the inputs succeeded
    if (in)
        s.revenue = s.units_sold * price;
    else 
        s = Sales_item();  // input failed: reset object to default state
    return in;
}

std::ostream& 
operator<<(std::ostream& out, const Sales_item& s)
{
    out << s.isbn() << " " << s.units_sold << " "
        << s.revenue << " " << s.avg_price();
    return out;
}

double Sales_item::avg_price() const
{
    if (units_sold) 
        return revenue/units_sold; 
    else 
        return 0;
}
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

#ifndef SCREEN_H
#define SCREEN_H

#include <string>

class Screen {
public:
    typedef std::string::size_type pos;

	// Action is a type that can point to a member function of Screen
    // that returns a reference to a Screen and takes no arguments
	using Action = Screen&(Screen::*)();

    // constructor: build screen of given size containing all blanks
    Screen(pos ht = 0, pos wd = 0): contents(ht * wd, ' '), cursor(0), 
                                    height(ht), width(wd) { }
	friend int main();
	// data is a static member that returns a pointer to member
	static const std::string Screen::*data() 
	    { return &Screen::contents; }

	char get_cursor() const { return contents[cursor]; }
    char get() const { return contents[cursor]; }
    inline char get(pos ht, pos wd) const;
private:
    std::string contents;
    pos cursor;
    pos height, width;

public:
	// cursor movement functions 
	// beware: these functions don't check whether the operation is valid
    Screen& home() { cursor = 0; return *this; }
    Screen& forward() { ++cursor; return *this; }
    Screen& back() { --cursor; return *this; }
    Screen& up() { cursor += height; return *this; }
    Screen& down() {cursor -= height; return *this; }

    // specify which direction to move; enum see XREF(enums)
    enum Directions { HOME, FORWARD, BACK, UP, DOWN };
    Screen& move(Directions);
private:
    static Action Menu[];      // function table
};

char Screen::get(pos r, pos c) const // declared as inline in the class
{
    pos row = r * width;      // compute row location
    return contents[row + c]; // return character at the given column
}

inline
Screen& Screen::move(Directions cm)
{
    // run the element indexed by cm on this object
    return (this->*Menu[cm])(); // Menu[cm] points to a member function
}

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
#include <iostream>

class Screen {
public:
    typedef std::string::size_type pos;
	Screen() = default;  // needed because Screen has another constructor
	// cursor initialized to 0 by its in-class initializer
    Screen(pos ht, pos wd, char c): height(ht), width(wd), 
	                                contents(ht * wd, c) { }
	friend class Window_mgr;
    Screen(pos ht = 0, pos wd = 0): 
       cursor(0), height(ht), width(wd), contents(ht * wd, ' ') { }
    char get() const              // get the character at the cursor
	    { return contents[cursor]; }       // implicitly inline
    inline char get(pos ht, pos wd) const; // explicitly inline
	Screen &clear(char = bkground);
private:
	static const char bkground = ' ';
public:
    Screen &move(pos r, pos c);      // can be made inline later
    Screen &set(char);
    Screen &set(pos, pos, char);
    // display overloaded on whether the object is const or not
    Screen &display(std::ostream &os) 
                  { do_display(os); return *this; }
    const Screen &display(std::ostream &os) const
                  { do_display(os); return *this; }
private:
     // function to do the work of displaying a Screen
     void do_display(std::ostream &os) const {os << contents;}
    pos cursor = 0;
    pos height = 0, width = 0;
    std::string contents;
};

Screen &Screen::clear(char c) 
{
	contents = std::string(height*width, c);
	return *this;
}

inline                   // we can specify inline on the definition
Screen &Screen::move(pos r, pos c)
{
    pos row = r * width; // compute the row location
    cursor = row + c;    // move cursor to the column within that row
    return *this;        // return this object as an lvalue
}

char Screen::get(pos r, pos c) const // declared as inline in the class
{
    pos row = r * width;      // compute row location
    return contents[row + c]; // return character at the given column
}

inline Screen &Screen::set(char c) 
{ 
    contents[cursor] = c; // set the new value at the current cursor location
    return *this;         // return this object as an lvalue
}
inline Screen &Screen::set(pos r, pos col, char ch)
{
	contents[r*width + col] = ch;  // set specified location to given value
	return *this;                  // return this object as an lvalue
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
#ifndef SMALL_SI_H
#define SMALL_SI_H

// This file isn't used in our code, but illustrates the
// definitions that are equivalent to Sales_data's 
// synthesized copy control members 

#include <string>

class Sales_data {
public:
    Sales_data(const std::string & s = ""): bookNo(s),
                                          units_sold(0), revenue(0.0) { }

	Sales_data(const std::string &book, unsigned cnt, double price):
	        bookNo(book), units_sold(cnt), revenue(cnt * price) { }

	// equivalent to the synthesized copy constructor
	Sales_data(const Sales_data &rhs): bookNo(rhs.bookNo),
                    units_sold(rhs.units_sold), revenue(rhs.revenue) { }

	// equivalent to the synthesized destructor
	// no work to do other than destroying the members, 
	// which happens automatically
    ~Sales_data() { } 
   
    Sales_data& operator=(const Sales_data &); // assignment operator
private:
    std::string bookNo;
    int units_sold = 0;
    double revenue = 0.0;
};

// equivalent to the synthesized copy-assignment operator
Sales_data& 
Sales_data::operator=(const Sales_data &rhs)
{
	bookNo = rhs.bookNo;          // calls the string::operator=
	units_sold = rhs.units_sold;  // uses the built-in int assignment
	revenue = rhs.revenue;        // uses the built-in double assignment
	return *this;                 // return a reference to this object
}

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

#ifndef STRBLOB_H
#define STRBLOB_H
#include <vector>
#include <string>
#include <initializer_list>
#include <memory>
#include <stdexcept>

// forward declaration needed for friend declaration in StrBlob
class StrBlobPtr;

class StrBlob {
	friend class StrBlobPtr;
public:
    typedef std::vector<std::string>::size_type size_type;

	// constructors
    StrBlob() : data(std::make_shared<std::vector<std::string>>()) { }
    StrBlob(std::initializer_list<std::string> il);

	// size operations
    size_type size() const { return data->size(); }
    bool empty() const { return data->empty(); }

    // add and remove elements
    void push_back(const std::string &t) { data->push_back(t); }
    void pop_back();

    // element access
    std::string& front();
    std::string& back();

	// interface to StrBlobPtr
	StrBlobPtr begin();  // can't be defined until StrBlobPtr is
    StrBlobPtr end();
private:
    std::shared_ptr<std::vector<std::string>> data; 
    // throws msg if data[i] isn't valid
    void check(size_type i, const std::string &msg) const;
};

// constructor
inline
StrBlob::StrBlob(std::initializer_list<std::string> il): 
              data(std::make_shared<std::vector<std::string>>(il)) { }

// StrBlobPtr throws an exception on attempts to access a nonexistent element 
class StrBlobPtr {
	friend bool eq(const StrBlobPtr&, const StrBlobPtr&);
public:
    StrBlobPtr(): curr(0) { }
    StrBlobPtr(StrBlob &a, size_t sz = 0): wptr(a.data), curr(sz) { }

    std::string& deref() const;
    StrBlobPtr& incr();       // prefix version
    StrBlobPtr& decr();       // prefix version
private:
    // check returns a shared_ptr to the vector if the check succeeds
    std::shared_ptr<std::vector<std::string>> 
        check(std::size_t, const std::string&) const;

    // store a weak_ptr, which means the underlying vector might be destroyed
    std::weak_ptr<std::vector<std::string>> wptr;  
    std::size_t curr;      // current position within the array
};

inline
std::string& StrBlobPtr::deref() const
{
    auto p = check(curr, "dereference past end"); 
    return (*p)[curr];  // (*p) is the vector to which this object points
}

inline
std::shared_ptr<std::vector<std::string>> 
StrBlobPtr::check(std::size_t i, const std::string &msg) const
{
    auto ret = wptr.lock();   // is the vector still around?
    if (!ret)
        throw std::runtime_error("unbound StrBlobPtr");

    if (i >= ret->size()) 
        throw std::out_of_range(msg);
    return ret; // otherwise, return a shared_ptr to the vector
}

// prefix: return a reference to the incremented object
inline
StrBlobPtr& StrBlobPtr::incr()
{
    // if curr already points past the end of the container, can't increment it
    check(curr, "increment past end of StrBlobPtr");
    ++curr;       // advance the current state
    return *this;
}

inline
StrBlobPtr& StrBlobPtr::decr()
{
    // if curr is zero, decrementing it will yield an invalid subscript
    --curr;       // move the current state back one element}
    check(-1, "decrement past begin of StrBlobPtr");
    return *this;
}

// begin and end members for StrBlob
inline
StrBlobPtr
StrBlob::begin() 
{
	return StrBlobPtr(*this);
}

inline
StrBlobPtr
StrBlob::end() 
{
	auto ret = StrBlobPtr(*this, data->size());
    return ret; 
}

// named equality operators for StrBlobPtr
inline
bool eq(const StrBlobPtr &lhs, const StrBlobPtr &rhs)
{
	auto l = lhs.wptr.lock(), r = rhs.wptr.lock();
	// if the underlying vector is the same 
	if (l == r) 
		// then they're equal if they're both null or 
		// if they point to the same element
		return (!r || lhs.curr == rhs.curr);
	else
		return false; // if they point to difference vectors, they're not equal
}

inline
bool neq(const StrBlobPtr &lhs, const StrBlobPtr &rhs)
{
	return !eq(lhs, rhs); 
}
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

#ifndef STRFOLDER_H
#define STRFOLDER_H

#include "String.h"
#include <set>

class Folder;

class Message {
	friend void swap(Message&, Message&);
	friend class Folder;
public:
    // folders is implicitly initialized to the empty set 
    explicit Message(const String &str = ""): 
		contents(str) { }  

    // copy control to manage pointers to this Message
    Message(const Message&);             // copy constructor
    Message& operator=(const Message&);  // copy assignment
    ~Message();                          // destructor
    Message(Message&&);            // move constructor
    Message& operator=(Message&&); // move assignment

    // add/remove this Message from the specified Folder's set of messages
    void save(Folder&);   
    void remove(Folder&); 
    void debug_print(); // print contents and it's list of Folders, 
                        // printing each Folder as well
private:
    String contents;      // actual message text
    std::set<Folder*> folders; // Folders that have this Message

    // utility functions used by copy constructor, assignment, and destructor
    // add this Message to the Folders that point to the parameter
    void add_to_Folders(const Message&);
	void move_Folders(Message*);
    // remove this Message from every Folder in folders
    void remove_from_Folders(); 

    // used by Folder class to add self to this Message's set of Folder's
    void addFldr(Folder *f) { folders.insert(f); }
    void remFldr(Folder *f) { folders.erase(f); }
};
// declaration for swap should be in the same header as Message itself
void swap(Message&, Message&);

class Folder {
	friend void swap(Message&, Message&);
	friend class Message;
public:
    ~Folder(); // remove self from Messages in msgs
    Folder(const Folder&); // add new folder to each Message in msgs
    Folder& operator=(const Folder&); // delete Folder from lhs messages
                                      // add Folder to rhs messages
    Folder(Folder&&);   // move Messages to this Folder 
    Folder& operator=(Folder&&); // delete Folder from lhs messages
                                 // add Folder to rhs messages

    Folder() = default; // defaults ok

    void save(Message&);   // add this message to folder
    void remove(Message&); // remove this message from this folder
    
    void debug_print(); // print contents and it's list of Folders, 
private:
    std::set<Message*> msgs;  // messages in this folder

    void add_to_Messages(const Folder&);// add this Folder to each Message
    void remove_from_Msgs();     // remove this Folder from each Message
    void addMsg(Message *m) { msgs.insert(m); }
    void remMsg(Message *m) { msgs.erase(m); }
	void move_Messages(Folder*); // move Message pointers to point to this Folder
};

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

#ifndef STRING_H
#define STRING_H

#include <cstring>
#include <algorithm>
#include <cstddef>
#include <iostream>
#include <initializer_list>
#include <iostream>
#include <memory>

class String {
friend String operator+(const String&, const String&);
friend String add(const String&, const String&);
friend std::ostream &operator<<(std::ostream&, const String&);
friend std::ostream &print(std::ostream&, const String&);

public:
	String() = default;

	// cp points to a null terminated array, 
	// allocate new memory & copy the array
	String(const char *cp) : 
	          sz(std::strlen(cp)), p(a.allocate(sz))
	          { std::uninitialized_copy(cp, cp + sz, p); }

	// copy constructor: allocate a new copy of the characters in s
	String(const String &s):sz(s.sz), p(a.allocate(s.sz))
	          { std::uninitialized_copy(s.p, s.p + sz , p); }

	// move constructor: copy the pointer, not the characters, 
	// no memory allocation or deallocation
	String(String &&s) noexcept : sz(s.size()), p(s.p) 
	          { s.p = 0; s.sz = 0; }

	String(size_t n, char c) : sz(n), p(a.allocate(n))
	          { std::uninitialized_fill_n(p, sz, c); }

	// allocates a new copy of the data in the right-hand operand; 
	// deletes the memory used by the left-hand operand
	String &operator=(const String &);
	// moves pointers from right- to left-hand operand
	String &operator=(String &&) noexcept;

	// unconditionally delete the memory because each String has its own memory
	~String() noexcept { if (p) a.deallocate(p, sz); }

	// additional assignment operators
	String &operator=(const char*);         // car = "Studebaker"
	String &operator=(char);                // model = 'T'
	String &
	operator=(std::initializer_list<char>); // car = {'a', '4'}
	
	const char *begin()                         { return p; }
	const char *begin() const                   { return p; }
	const char *end()                      { return p + sz; }
	const char *end() const                { return p + sz; }

	size_t size() const                        { return sz; }
	void swap(String &s)
	                { auto tmp = p; p = s.p; s.p = tmp; 
	                  auto cnt = sz; sz = s.sz; s.sz = cnt; }
private:
	std::size_t sz = 0;
	char *p = nullptr;
	static std::allocator<char> a;
};
String make_plural(size_t ctr, const String &, const String &);
inline
void swap(String &s1, String &s2)
{
	s1.swap(s2);
}

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

#ifndef STRVEC_H
#define STRVEC_H

#include <iostream>
#include <memory>
#include <utility>
#include <initializer_list>

// simplified implementation of the memory allocation strategy for a vector-like class
class StrVec {
public:
	// copy control members
    StrVec(): 
	  elements(nullptr), first_free(nullptr), cap(nullptr) { }

	StrVec(const StrVec&);            // copy constructor
	StrVec &operator=(const StrVec&); // copy assignment

	StrVec(StrVec&&) noexcept;            // move constructor
	StrVec &operator=(StrVec&&) noexcept; // move assignment

	~StrVec() noexcept;                   // destructor

	// additional constructor
	StrVec(std::initializer_list<std::string>);

    void push_back(const std::string&);  // copy the element
    void push_back(std::string&&);       // move the element

	// add elements
    size_t size() const { return first_free - elements; }
    size_t capacity() const { return cap - elements; }

	// iterator interface
	std::string *begin() const { return elements; }
	std::string *end() const { return first_free; }
    
	// operator functions covered in chapter 14
	StrVec &operator=(std::initializer_list<std::string>);   

	std::string& operator[](std::size_t n) 
		{ return elements[n]; }

	const std::string& operator[](std::size_t n) const 
		{ return elements[n]; }
	
	// emplace member covered in chapter 16
	template <class... Args> void emplace_back(Args&&...);
private:
    static std::allocator<std::string> alloc; // allocates the elements

	// utility functions:
	//  used by members that add elements to the StrVec
	void chk_n_alloc() 
		{ if (size() == capacity()) reallocate(); }
    // used by the copy constructor, assignment operator, and destructor
	std::pair<std::string*, std::string*> alloc_n_copy
	    (const std::string*, const std::string*);
	void free();             // destroy the elements and free the space
    void reallocate();       // get more space and copy the existing elements
    std::string *elements;   // pointer to the first element in the array
    std::string *first_free; // pointer to the first free element in the array
    std::string *cap;        // pointer to one past the end of the array
};

#include <algorithm>

inline
StrVec::~StrVec() noexcept { free(); }

inline
std::pair<std::string*, std::string*> 
StrVec::alloc_n_copy(const std::string *b, const std::string *e)
{
	// allocate space to hold as many elements as are in the range
	auto data = alloc.allocate(e - b); 

	// initialize and return a pair constructed from data and
	// the value returned by uninitialized_copy
	return {data, uninitialized_copy(b, e, data)};
}

inline
StrVec::StrVec(StrVec &&s) noexcept  // move won't throw any exceptions
  // member initializers take over the resources in s
  : elements(s.elements), first_free(s.first_free), cap(s.cap)
{
	// leave s in a state in which it is safe to run the destructor
	s.elements = s.first_free = s.cap = nullptr;
}

inline
StrVec::StrVec(const StrVec &s)
{
	// call alloc_n_copy to allocate exactly as many elements as in s
	auto newdata = alloc_n_copy(s.begin(), s.end());
	elements = newdata.first; 
	first_free = cap = newdata.second;
}

inline
void StrVec::free()
{
    // may not pass deallocate a 0 pointer; if elements is 0, there's no work to do
	if (elements) {
    	// destroy the old elements in reverse order
		for (auto p = first_free; p != elements; /* empty */)
			alloc.destroy(--p);  
		alloc.deallocate(elements, cap - elements);
	}
}
	
inline
StrVec &StrVec::operator=(std::initializer_list<std::string> il)
{
	// alloc_n_copy allocates space and copies elements from the given range
	auto data = alloc_n_copy(il.begin(), il.end());
	free();   // destroy the elements in this object and free the space
	elements = data.first; // update data members to point to the new space
	first_free = cap = data.second;
	return *this;
}

inline
StrVec &StrVec::operator=(StrVec &&rhs) noexcept
{
	// direct test for self-assignment
	if (this != &rhs) {
		free();                   // free existing elements 
		elements = rhs.elements;  // take over resources from rhs
		first_free = rhs.first_free;
		cap = rhs.cap;
		// leave rhs in a destructible state
		rhs.elements = rhs.first_free = rhs.cap = nullptr;
	}
	return *this;
}

inline
StrVec &StrVec::operator=(const StrVec &rhs)
{
	// call alloc_n_copy to allocate exactly as many elements as in rhs
	auto data = alloc_n_copy(rhs.begin(), rhs.end());
	free();
	elements = data.first;
	first_free = cap = data.second;
	return *this;
}

inline
void StrVec::reallocate()
{
    // we'll allocate space for twice as many elements as the current size
    auto newcapacity = size() ? 2 * size() : 1;

	// allocate new memory
	auto newdata = alloc.allocate(newcapacity);

	// move the data from the old memory to the new
	auto dest = newdata;  // points to the next free position in the new array
    auto elem = elements; // points to the next element in the old array
	for (size_t i = 0; i != size(); ++i)
		alloc.construct(dest++, std::move(*elem++));

	free();  // free the old space once we've moved the elements

    // update our data structure to point to the new elements
    elements = newdata;
    first_free = dest;
    cap = elements + newcapacity;
}

inline
StrVec::StrVec(std::initializer_list<std::string> il)
{
	// call alloc_n_copy to allocate exactly as many elements as in il
	auto newdata = alloc_n_copy(il.begin(), il.end());
	elements = newdata.first;
	first_free = cap = newdata.second;
}

inline
void StrVec::push_back(const std::string& s)
{
    chk_n_alloc(); // ensure that there is room for another element
    // construct a copy of s in the element to which first_free points
    alloc.construct(first_free++, s);  
}

inline
void StrVec::push_back(std::string &&s) 
{
    chk_n_alloc(); // reallocates the StrVec if necessary
	alloc.construct(first_free++, std::move(s));
}

 
// emplace member covered in chapter 16
template <class... Args>
inline
void StrVec::emplace_back(Args&&... args)
{
    chk_n_alloc(); // reallocates the StrVec if necessary
	alloc.construct(first_free++, std::forward<Args>(args)...);
}

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

#ifndef TEXTQUERY_H
#define TEXTQUERY_H
#include <memory>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <iostream>
#include <fstream>
#include <cctype>
#include <cstring>
#include <cassert>
#include <cstdlib>
#include <utility>

class TextQuery {
public:
	class QueryResult;  // nested class to be defined later
	// other members as in XREF(TextQueryClass)
	typedef std::vector<std::string>::size_type line_no;
	TextQuery(std::ifstream&);
    QueryResult query(const std::string&) const; 
    void display_map();        // debugging aid: print the map
private:
    std::shared_ptr<std::vector<std::string>> file; // input file
    // map of each word to the set of the lines in which that word appears
    std::map<std::string, 
	         std::shared_ptr<std::set<line_no>>> wm;  
    // characters that constitute whitespace
    static std::string whitespace_chars;     
	// canonicalizes text: removes punctuation and makes everything lower case
    static std::string cleanup_str(const std::string&);
};

//we're defining the QueryResult class that is a member of class TextQuery
class TextQuery::QueryResult {
	// in class scope, we don't have to qualify the name of the QueryResult parameters
	friend std::ostream&
	       print(std::ostream&, const QueryResult&);
public:
	// no need to define QueryResult::line_no; a nested class can use a member 
	// of its enclosing class without needing to qualify the member's name
	QueryResult(std::string, 
	            std::shared_ptr<std::set<line_no>>,  
	            std::shared_ptr<std::vector<std::string>>);
    // other members as in XREF(TextQueryClass)
	typedef std::set<line_no>::const_iterator line_it;
	std::set<line_no>::size_type size() const  { return lines->size(); }
	line_it begin() const { return lines->cbegin(); }
	line_it end() const   { return lines->cend(); }
	std::shared_ptr<std::vector<std::string>> get_file() { return file; }
private:
	std::string sought;  // word this query represents
	std::shared_ptr<std::set<line_no>> lines; // lines it's on
	std::shared_ptr<std::vector<std::string>> file;  //input file
	static int static_mem;
};
std::ostream &print(std::ostream&, const TextQuery::QueryResult&);

using std::shared_ptr; using std::string; using std::set;
using std::vector;

inline
// defining the member named QueryResult for the class named QueryResult
// that is nested inside the class TextQuery
TextQuery::QueryResult::QueryResult(string s, 
	            shared_ptr<set<line_no>> p,  
	            shared_ptr<vector<string>> f):
		sought(s), lines(p), file(f) { }
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

#ifndef TEXTQUERY_H
#define TEXTQUERY_H
#include <memory>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <fstream>
#include "QueryResult.h"

/* this version of the query classes includes two
 * members not covered in the book:  
 *   cleanup_str: which removes punctuation and 
 *                converst all text to lowercase
 *   display_map: a debugging routine that will print the contents
 *                of the lookup mape
*/

class QueryResult; // declaration needed for return type in the query function
class TextQuery {
public:
	using line_no = std::vector<std::string>::size_type;
	TextQuery(std::ifstream&);
    QueryResult query(const std::string&) const; 
    void display_map();        // debugging aid: print the map
private:
    std::shared_ptr<std::vector<std::string>> file; // input file
    // maps each word to the set of the lines in which that word appears
    std::map<std::string, 
	         std::shared_ptr<std::set<line_no>>> wm;  

	// canonicalizes text: removes punctuation and makes everything lower case
    static std::string cleanup_str(const std::string&);
};
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

#ifndef TOKEN_H
#define TOKEN_H

#include <string>
using std::string;

#include <iostream>

#include "Token.h"

class Token {
friend std::ostream &operator<<(std::ostream&, const Token&);
public:
	// copy control needed because our class has a union with a string member
	// defining the move constructor and move-assignment operator is left as an exercise
	Token(): tok(INT), ival{0} { }
	Token(const Token &t): tok(t.tok) { copyUnion(t); }
	Token &operator=(const Token&);
	// if the  union holds a string, we must destroy it; see XREF(expldtor)
	~Token() { if (tok == STR) sval.~string(); }
	// assignment operators to set the differing members of the union
	Token &operator=(const std::string&);
	Token &operator=(char);
	Token &operator=(int);
	Token &operator=(double);
private:
    enum {INT, CHAR, DBL, STR} tok; // discriminant
    union {                         // anonymous union 
        char   cval;
        int    ival;
        double dval;
		std::string sval;
    }; // each Token object has an unnamed member of this unnamed union type
	// check the discriminant and copy the union member as appropriate
	void copyUnion(const Token&);  
};

inline
void Token::copyUnion(const Token &t)
{
	switch (t.tok) {
		case Token::INT: ival = t.ival; break;
		case Token::CHAR: cval = t.cval; break;
		case Token::DBL: dval = t.dval; break;
		// to copy a string, construct it using placement new; see (XREF(placenew)) 
		case Token::STR: new(&sval) std::string(t.sval); break;
	}
}

inline
std::ostream &operator<<(std::ostream &os, const Token &t)
{
	switch (t.tok) {
		case Token::INT: return os << t.ival;
		case Token::CHAR: return os << t.cval;
		case Token::DBL: return os << t.dval;
		case Token::STR: return os << t.sval;
	}
}

inline
Token &Token::operator=(double d)
{
	if (tok == STR) sval.~string();  // if we have a string, free it
	dval = d;
	tok = DBL;
	return *this;
}

inline
Token &Token::operator=(char c)
{
	if (tok == STR) sval.~string();  // if we have a string, free it
	cval = c;
	tok = CHAR;
	return *this;
}

inline
Token &Token::operator=(int i)
{
	if (tok == STR) sval.~string();  // if we have a string, free it
	ival = i;                        // assign to the appropriate member
	tok = INT;                       // update the discriminant
	return *this;
}

inline
Token &Token::operator=(const std::string &s)
{
	if (tok == STR)  // if we already hold a string, just do an assignment
		sval = s;
	else
		new(&sval) std::string(s);  // otherwise construct a string
	tok = STR;                 // update the discriminant
	return *this;
}

inline
Token &Token::operator=(const Token &t)
{
	// if this object holds a string and t doesn't, we have to free the old string
	if (tok == STR && t.tok != STR) sval.~string();
	if (tok == STR && t.tok == STR)
		sval = t.sval;  // no need to construct a new string
	else
		copyUnion(t);   // will construct a string if t.tok is STR
	tok = t.tok;
	return *this;
}
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

#ifndef VEC_H
#define VEC_H

#include <algorithm>
#include <memory>
#include <utility>
#include <initializer_list>

// simplified-implementation of memory allocation strategy for a vector-like class
template <typename T>
class Vec {
public:
    Vec() = default;
	Vec(const Vec&);                 // copy constructor
	Vec(Vec&&) noexcept;             // move constructor
	Vec &operator=(const Vec&);      // copy assignment
	Vec &operator=(Vec&&) noexcept;  // move assignment
	~Vec() noexcept;                 // destructor

	// list assignment
	Vec &operator=(std::initializer_list<T>);   

	// add elements
    void push_back(const T&);
    void push_back(T&&);
	template <class... Args> void emplace_back(Args&&...);
	
	// size and capacity
    size_t size() const { return first_free - elements; }
    size_t capacity() const { return cap - elements; }

	// element access
    T& operator[](size_t n) { return elements[n]; }
    const T& operator[](size_t n) const { return elements[n]; }

	// iterator interface
	T *begin() const { return elements; }
	T *end() const { return first_free; }
private:
    static std::allocator<T> alloc; // allocates the elements
	// used by functions that add elements to the Vec
	void chk_n_alloc() { if (first_free == cap) reallocate(); }

    // utilities used by copy constructor, assignment operator, and destructor
	std::pair<T*, T*> 
	  alloc_n_copy(const T*, const T*);
	void free();
    void reallocate(); // get more space and copy existing elements
    T* elements = nullptr;   // pointer to first element in the array
    T* first_free = nullptr; // pointer to first free element in the array
    T* cap = nullptr;        // pointer to one past the end of the array
};


//definition for the static data member 
template <typename T> std::allocator<T> Vec<T>::alloc;  

template <typename T>
inline
Vec<T>::~Vec() noexcept { free(); }

template <typename T>
inline
std::pair<T*, T*> 
Vec<T>::alloc_n_copy(const T *b, const T *e) 
{
	auto data = alloc.allocate(e - b);
	return {data, uninitialized_copy(b, e, data)};
}

template <typename T>
inline
Vec<T>::Vec(Vec &&s) noexcept : 
	// take over resources from s
	elements(s.elements), first_free(s.first_free), cap(s.cap)
{
	// leave s in a state in which it is safe to run the destructor
	s.elements = s.first_free = s.cap = nullptr;
}

template <typename T>
inline
Vec<T>::Vec(const Vec &s)
{
	// call copy to allocate exactly as many elements as in s
	auto newdata = alloc_n_copy(s.begin(), s.end()); 
	elements = newdata.first; 
	first_free = cap = newdata.second;
}

template <typename T>
inline
void Vec<T>::free()
{
    // destroy the old elements in reverse order
	for (auto p = first_free; p != elements; /* empty */)
		alloc.destroy(--p);  // destroy elements in reverse order
    
    // deallocate cannot be called on a 0 pointer
	if (elements)
		alloc.deallocate(elements, cap - elements);
}
	
template <typename T>
inline
Vec<T> &Vec<T>::operator=(std::initializer_list<T> il)
{
	// copy allocates space and copies elements from the given range
	auto data = alloc_n_copy(il.begin(), il.end());

	free();   // destroy the elements in this object and free the space

	elements = data.first; // update data members to point to the new space
	first_free = cap = data.second;

	return *this;
}

template <typename T>
inline
Vec<T> &Vec<T>::operator=(Vec &&rhs) noexcept
{
	// direct test for self-assignment
	if (this != &rhs)
		free();  // free existing elements if appropriate

	elements = rhs.elements;  // take over resources from rhs
	first_free = rhs.first_free;
	cap = rhs.cap;

	// leave rhs in a destructible state
	rhs.elements = rhs.first_free = rhs.cap = nullptr;

	return *this;
}

template <typename T>
inline
Vec<T> &Vec<T>::operator=(const Vec &rhs)
{
	// call copy to allocate exactly as many elements as in rhs
	auto data = alloc_n_copy(rhs.begin(), rhs.end());
	free();
	elements = data.first;
	first_free = cap = data.second;
	return *this;
}

template <typename T>
inline
void Vec<T>::reallocate()
{
    // we'll allocate space for twice as many elements as current size
    auto newcapacity = size() ? 2 * size() : 2;

	// allocate new space
	auto first = alloc.allocate(newcapacity);
	auto dest = first;
	auto elem = elements;

	// move the elements
	for (size_t i = 0; i != size(); ++i)
		alloc.construct(dest++, std::move(*elem++));
	free();  // free the old space once we've moved the elements

    // update our data structure point to the new elements
    elements = first;
    first_free = dest;
    cap = elements + newcapacity;
}

template <typename T>
inline
void Vec<T>::push_back(const T& s)
{
    chk_n_alloc(); // reallocates the Vec if necessary
    // construct a copy s in the element to which first_free points
    alloc.construct(first_free++, s);  
}

template <typename T>
inline
void Vec<T>::push_back(T&& s) 
{
    chk_n_alloc(); // reallocates the Vec if necessary
	alloc.construct(first_free++, std::move(s));
}

template <typename T>
template <class... Args>
inline
void Vec<T>::emplace_back(Args&&... args)
{
    // any space left?
    chk_n_alloc(); // reallocates the Vec if necessary
	alloc.construct(first_free++, std::forward<Args>(args)...);
}

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

#ifndef VERSION_TEST_H
#define VERSION_TEST_H


/* As of the first printing of C++ Primer, 5th Edition (July 2012), 
 * the gcc Version 4.7.0 did not yet support some C++ 11 features.  
 *
 * The code we distribute contains both normal C++ code and 
 * workarounds for missing features.  We use preprocessor variables to
 * determine whether a given features is implemented in a given release
 * of the compiler.  
 * The base version we used to test the code in the book
 * is gcc version 4.7.0 (GCC) 
 *
 * When new releases are available we will update this file which will
 * #define the features implmented in that release.
*/

#if __cplusplus == 201103L 
// base version, future releases of this file will 
// #define these variables as features as they are implemented 

/* Code in this delivery use the following variables to control compilation

   Variable tests           C++ 11 Feature 
HEX_MANIPS               hexfloat and defaultfloat manipulators
REFMEMS                  reference qualified member functions
REGEX                    regular expressions library
STRING_NUMERIC_CONVS     conversions to and from string to numeric
*/
#endif  // ends compiler version check

#ifndef STRING_NUMERIC_CONVS
// if the library doesn't define to_string 
// or the numeric conversion functions
// as a workaround we define to_string and stod in this file

// Readers can ignore the implemnetations of to_string and stod 
// but can use these functions in their code.

#include <iostream>
#include <cstdlib>
#include <cstddef>
#include <string>
// we use sprintf from stdio to implement to_string
#include <cstdio>

inline
std::string to_string(int i)
{
	char buf[100];
	std::sprintf(buf, "%d", i);
	return buf;
}

inline
double stod(const std::string &s, std::size_t * = 0)
{
	char **buf = 0;
	return std::strtod(s.c_str(), buf);
}
#endif   // STRING_NUMERIC_CONVS

#include <iostream>

#ifndef HEX_MANIPS
inline
std::ostream &defaultfloat(std::ostream &os) 
{
	os.unsetf(std::ios_base::floatfield);
	return os;
}
#endif   // HEX_MANIPS

#endif  // ends header guard

/*
 * This file contains code from "C++ Primer, Fifth Edition", by Stanley B.
 * Lippman, Josee Lajoie, and Barbara E. Moo, and is covered under the
 * copyright and warranty notices given in that book:
 * 
 * "Copyright (c) 2013 by Objectwrite, Inc., Josee Lajoie, and Barbara E. Moo."
 * 
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

#ifndef WINDOW_MGR
#define WINDOW_MGR

#include <vector>
#include <string>
#include <iostream>
#include "newscreen.h"

class BitMap;
// overloaded storeOn functions
extern std::ostream& storeOn(std::ostream &, Screen &);
extern BitMap& storeOn(BitMap &, Screen &);

class Window_mgr {
public:
	// location ID for each screen on the window
	using ScreenIndex = std::vector<Screen>::size_type;

	// add a Screen to the window and returns its index
	ScreenIndex addScreen(const Screen&);
	
	// reset the Screen at the given position to all blanks
	void clear(ScreenIndex);

	// change dimensions of a given Screen
	void resize(Screen::pos r, Screen::pos c, ScreenIndex i);
private:
	// Screens this Window_mgr is tracking
	// by default, a Window_mgr has one standard sized blank Screen 
	std::vector<Screen> screens{Screen(24, 80, ' ')};
};

// return type is seen before we're in the scope of Window_mgr
inline
Window_mgr::ScreenIndex
Window_mgr::addScreen(const Screen &s)
{
	screens.push_back(s);
	return screens.size() - 1;
}

inline
void Window_mgr::clear(ScreenIndex i)
{
	// s is a reference to the Screen we want to clear
	Screen &s = screens[i];
	// reset the contents of that Screen to all blanks
	s.contents = std::string(s.height * s.width, ' ');
}

inline
void
Window_mgr::resize(Screen::pos r, Screen::pos c, ScreenIndex i)
{
    screens[i].height = r;  // Window_mgr is a friend of Screen
    screens[i].width = c;   // so it is ok to use Screen's private members
	// resize and clear the contents member
	screens[i].contents = std::string(r * c, ' '); 
}

#endif
