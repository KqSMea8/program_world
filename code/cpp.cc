#include <iostream>
#include <stdexcept>
using namespace std;

istream& f(istream &in)
{
    int v;
    while (in >> v, !in.eof())  // 直到遇到文件结束符才停止读取
    {
        if (in.bad())
        {
            throw runtime_error("IO流错误");
        }

        if (in.fail())
        {
            cerr << "数据错误，请重试：" << endl;
            in.clear();
            in.ignore(100, '\n');
            continue;
        }
        cout << v << endl;
    }
    in.clear();
    return in;
}

int main()
{
    cout << "请输入一些整数，按Ctrl+Z结束" << endl;
    f(cin);
    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<int> vi;
    int val;
    while (in >> val)
    {
        vi.push_back(val);
    }

    cout << "请输入要搜索的整数：";
    cin >> val;
    cout << "序列中包含" << count(vi.begin(), vi.end(), val) << "个" << val;
    return 0;
}
锘?include <cstdlib>
#include <new>
using namespace std;

void *operator new(size_t size)
{
    if (void *mem = malloc(size))
    {
        return mem;
    }
    else
    {
        throw bad_alloc();
    }
}

void operator delete(void *mem) noexcept
{
    free(mem);
}

int main()
{
    return 0;
}

#include <iostream>
#include "Sales_data.h"
using namespace std;

int main()
{
    cout << "璇疯緭鍏ヤ氦鏄撹褰曪紙ISBN銆侀攢鍞噺銆佸師浠枫€佸疄闄呭敭浠凤級锛? << endl;
    Sales_data total; //淇濆瓨涓嬩竴鏉′氦鏄撹褰曠殑鍙橀噺
    // 璇诲叆绗竴鏉′氦鏄撹褰曪紝骞剁‘淇濇湁鏁版嵁鍙互澶勭悊
    if (cin >> total)
    {
        Sales_data trans; //淇濆瓨鍜岀殑鍙橀噺
        //璇诲叆骞跺鐞嗗墿浣欎氦鏄撹褰?
        while (cin >> trans)
        {
            //濡傛灉鎴戜滑浠嶅湪澶勭悊鐩稿悓鐨勪功
            if (total.isbn() == trans.isbn())
            {
                total += trans; //鏇存柊鎬婚攢鍞
            }
            else
            {
                //鎵撳嵃鍓嶄竴鏈功鐨勭粨鏋?
                cout << total << endl;
                total = trans; //total鐜板湪琛ㄧず涓嬩竴鏈功鐨勯攢鍞
            }
        }
        cout << total << endl; //鎵撳嵃鏈€鍚庝竴鏈功鐨勭粨鏋?
    }
    else
    {
        //娌℃湁杈撳叆锛佽鍛婅鑰?
        cerr << "No data?!" << endl;
        return -1; //琛ㄧず澶辫触
    }
    return 0;
}
#include <iostream>
using namespace std;

int main()
{
    unsigned int aCnt = 0, eCnt = 0, iCnt = 0, oCnt = 0, uCnt = 0;
    char ch;
    cout << "请输入一段文本：" << endl;
    while (cin >> ch)
    {
        switch (ch)
        {
            case 'a':
            case 'A':
                ++aCnt;
                break;
            case 'e':
            case 'E':
                ++eCnt;
                break;
            case 'i':
            case 'I':
                ++iCnt;
                break;
            case 'o':
            case 'O':
                ++oCnt;
                break;
            case 'u':
            case 'U':
                ++uCnt;
                break;
       }
    }
    cout << "元音字母a的数量是：" << aCnt << endl;
    cout << "元音字母e的数量是：" << eCnt << endl;
    cout << "元音字母i的数量是：" << iCnt << endl;
    cout << "元音字母o的数量是：" << oCnt << endl;
    cout << "元音字母u的数量是：" << uCnt << endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

using namespace std;

int main()
{
    ifstream in("data");          // 打开文件
    if (!in)
    {
        cerr << "无法打开输入文件" << endl;
        return -1;
    }

    string line;
    vector<string> words;
    while (getline(in, line))   // 从文件中读取一行
    {
        words.push_back(line);      // 添加到vector中
    }

    in.close();                   // 输入完毕，关闭文件

    vector<string>::const_iterator it = words.begin();  // 迭代器
    while (it != words.end())  // 遍历vector
    {
        istringstream line_str(*it);
        string word;
        while (line_str >> word)    // 通过istringstream从vector中读取数据
        {
            cout << word << " ";
        }
        cout << endl;
        ++it;
    }

    return 0;
}
#include <iostream>
#include <bitset>
using namespace std;

int main(int argc, char **argv)
{
    unsigned bp = 2 | (11 << 2) | (1 << 5) | (1 << 8) | (1 << 13) | (1 << 21);
	bitset<32> bv(bp);
	cout << bv << endl;

	bitset<32> bv1;
	bv1.set(1); bv1.set(2); bv1.set(3); bv1.set(5);
	bv1.set(8); bv1.set(13); bv1.set(21);
	cout << bv1 << endl;

	return 0;
}
#include <iostream>

int main()
{
    int i = 10;
    while (i >= 0)
    {
        std::cout << i << " ";
        i--;
    }
    std::cout << std::endl;
    return 0;
}
#include <iostream>
using namespace std;

//在函数体内部通过解引用操作改变指针所指的内容
void mySWAP(int *p, int *q)
{
    int tmp = *p;	//tmp是个整数
    *p = *q;
    *q = tmp;
}

int main()
{
    int a = 5, b = 10;
    int *r = &a, *s = &b;
    cout << "交换前：a = " << a << "，b = " << b << endl;
    mySWAP(r, s);
    cout << "交换后：a = " << a << "，b = " << b << endl;
    return 0;
}
#include <iostream>
#include <string>
#include <cctype>
using namespace std;

int main()
{
    string s;
    cout << "请输入一个字符串，最好含有某些标点符号：" << endl;
    getline(cin, s);
    for (auto c : s)
    {
        if (!ispunct(c))
        {
            cout << c;
        }
    }
    cout << endl;
    return 0;
}
#include <iostream>
using namespace std;

//在函数体内部交换了两个形参指针本身的值，未能影响实参
void mySWAP(int *p, int *q)
{
    int *tmp = p;	//tmp是个指针
    p = q;
    q = tmp;
}

int main()
{
    int a = 5, b = 10;
    int *r = &a, *s = &b;
    cout << "交换前：a = " << a << "，b = " << b << endl;
    mySWAP(r, s);
    cout << "交换后：a = " << a << "，b = " << b << endl;
    return 0;
}
#include <iostream>
#include <string>
#include <cctype>
using namespace std;

int main()
{
    string s, result;
    cout << "请输入一个字符串，最好含有某些标点符号：" << endl;
    getline(cin, s);
    for (decltype(s.size()) i = 0; i < s.size(); i++)
    {
        if (!ispunct(s[i]))
        {
            result += s[i];
        }
    }
    cout << result << endl;
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    const string s = "Keep out!";
    for (auto &c : s)
    {
        c='X';  // error: assignment of read-only reference to 'c'.
        //其它对c的操作
    }
    return 0;
}
#include <iostream>
using namespace std;

int main()
{
    unsigned int aCnt = 0, eCnt = 0, iCnt = 0, oCnt = 0, uCnt = 0;
    unsigned int spaceCnt = 0, tabCnt = 0, newlineCnt = 0;
    char ch;
    cout << "请输入一段文本：" << endl;
    while (cin.get(ch))
    {
        switch(ch)
        {
            case 'a':
            case 'A':
                ++aCnt;
                break;
            case 'e':
            case 'E':
                ++eCnt;
                break;
            case 'i':
            case 'I':
                ++iCnt;
                break;
            case 'o':
            case 'O':
                ++oCnt;
                break;
            case 'u':
            case 'U':
                ++uCnt;
                break;
            case ' ':
                ++spaceCnt;
                break;
            case '\t':
                ++tabCnt;
                break;
            case '\n':
                ++newlineCnt;
                break;
        }
    }
    cout << "元音字母a的数量是：" << aCnt << endl;
    cout << "元音字母e的数量是：" << eCnt << endl;
    cout << "元音字母i的数量是：" << iCnt << endl;
    cout << "元音字母o的数量是：" << oCnt << endl;
    cout << "元音字母u的数量是：" << uCnt << endl;
    cout << "空格的数量是：" << spaceCnt << endl;
    cout << "制表符的数量是：" << tabCnt << endl;
    cout << "换行符的数量是：" << newlineCnt << endl;
    return 0;
}
#include <iostream>
using namespace std;

void reset(int &i)
{
    i = 0;
}

int main()
{
    int num = 10;
    cout << "重置前：num = " << num << endl;
    reset(num);
    cout << "重置后：num = " << num << endl;
    return 0;
}
#include <iostream>
#include "Sales_data.h"
using namespace std;

int main()
{
    Sales_data data1;
    Sales_data data2("978-7-121-15535-2");
    Sales_data data3("978-7-121-15535-2", 100, 128, 109);
    Sales_data data4(cin);

    cout << "涔︾睄鐨勯攢鍞儏鍐垫槸锛? << endl;
    cout << data1 << "\n" << data2 << "\n" << data3 << "\n" << data4 << "\n";
    return 0;
}
#include <iostream>
#include <sstream>
#include <string>
#include <vector>
using namespace std;

struct PersonInfo
{
	string name;
  	vector<string> phones;
};

int main()
{
	string line, word; 				    // 分别保存来自输入的一行和单词
	vector<PersonInfo> people; 		// 保存来自输入的所有记录
	istringstream record;

	while (getline(cin, line))
	{
		PersonInfo info; 			      // 创建一个保存此记录数据的对象
		record.clear();             // 重复使用字符串流时，每次都要调用clear
		record.str(line);	          // 将记录绑定到刚读入的行
		record >> info.name; 		    // 读取名字
		while (record >> word)   	  // 读取电话号码
		{
			info.phones.push_back(word); // 保持它们
		}

		people.push_back(info); 		// 将此记录追加到people末尾
	}

  return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> ilist = {1, 2, 3.0, 4, 5, 6, 7};      // 列表初始化
    vector<int> ilist_1{1, 2, 3.0, 4, 5, 6, 7};
    vector<int> ilist1;                               // 默认初始化
    vector<int> ilist2(ilist);                        // 拷贝初始化
    vector<int> ilist2_1=ilist;
    vector<int> ilist3(ilist.begin()+2, ilist.end()-1);   // 范围初始化
    vector<int> ilist4(7);                            // 缺省值初始化
    vector<int> ilist5(7, 3);                            // 指定值初始化

    cout << ilist.capacity() << " " << ilist.size() << endl;
    cout << ilist_1.capacity() << " " << ilist_1.size() << endl;
    cout << ilist1.capacity() << " " << ilist1.size() << endl;
    cout << ilist2.capacity() << " " << ilist2.size() << endl;
    cout << ilist2_1.capacity() << " " << ilist2_1.size() << endl;
    cout << ilist3.capacity() << " " << ilist3.size() << " " << ilist3[0] << " " << ilist3[ilist3.size()-1]  << endl;
    cout << ilist4.capacity() << " " << ilist4.size() << " " << ilist4[0] << " " << ilist4[ilist4.size()-1]  << endl;
    cout << ilist5.capacity() << " " << ilist5.size() << " " << ilist5[0] << " " << ilist5[ilist5.size()-1]  << endl;

    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

inline void output_words(vector<string> &words)
{
    for (auto iter = words.begin(); iter != words.end(); iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;
}

bool isShorter(const string &s1, const string &s2)
{
    return s1.size() < s2.size();
}

void elimDups(vector<string> &words)
{
    output_words(words);

    sort(words.begin(), words.end());
    output_words(words);

    auto end_unique = unique(words.begin(), words.end());
    output_words(words);

    words.erase(end_unique, words.end());
    output_words(words);

    stable_sort(words.begin(), words.end(), isShorter);
    output_words(words);
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<string> words;
    string word;
    while (in >> word)
    {
        words.push_back(word);
    }

    elimDups(words);
    return 0;
}
#include <iostream>
#include <bitset>
using namespace std;

template <size_t N>
class exam
{
public:
    exam() : s() {}
    size_t get_size() { return N; }
    void set_solution(size_t n, bool b) { s.set(n, b); }
    bitset<N> get_solution() const { return s; }
    size_t score(const bitset<N> &a);
private:
    bitset<N> s;
};

template <size_t N>
size_t exam<N>::score(const bitset<N> &a)
{
    size_t ret = 0;

    for (size_t i = 0; i < N; i++)
    {
        if (s[i] == a[i])
        {
            ret++;
        }
    }

    return ret;
}

int main(int argc, char **argv)
{
    exam<80> e;
    e.set_solution(0, 1);
    e.set_solution(79, 1);
    cout << e.get_solution() << endl;

    bitset<80> a;
    cout << e.get_size() << "棰樺浜? << e.score(a) << "棰? << endl;

  	return 0;
}
#include <iostream>

int main()
{
    std::cout << "请输入两个数";
    std::cout << std::endl;
    int v1, v2;
    std::cin >> v1 >> v2;
    if (v1 > v2)	// 由大至小打印
    {
        while (v1 >= v2)
        {
            std::cout << v1 << " ";
            v1--;
        }
    }
    else				// 由小至大打印
    {
        while (v1 <= v2)
        {
            std::cout << v1 << " ";
            v1++;
        }
    }
    std::cout << std::endl;
    return 0;
}
#include <iostream>
using namespace std;

void mySWAP(int &i, int &j)
{
    int tmp = i;
    i = j;
    j = tmp;
}

int main()
{
    int a = 5, b = 10;
    cout << "交换前：a = " << a << "，b = " << b << endl;
    mySWAP(a, b);
    cout << "交换后：a = " << a << "，b = " << b << endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
using namespace std;

struct PersonInfo
{
    string name;
    vector<string> phones;
};

string format(const string &s) { return s; }

bool valid(const string &s)
{
  	// we'll see how to validate phone numbers
  	// in chapter 17, for now just return true
  	return true;
}

int main(int argc, char *argv[])
{
  	string line, word; 				    // 分别保存来自输入的一行和单词
  	vector<PersonInfo> people; 		// 保存来自输入的所有记录
  	istringstream record;

    if (argc != 2)
    {
        cerr << "请给出文件名" << endl;
        return -1;
    }

    ifstream in(argv[1]);
    if (!in)
    {
        cerr << "无法打开输入文件" << endl;
        return -1;
    }

  	while (getline(in, line))
    {
    		PersonInfo info; 			      // 创建一个保存此记录数据的对象
    		record.clear();             // 重复使用字符串流时，每次都要调用clear
    		record.str(line);	          // 将记录绑定到刚读入的行
    		record >> info.name; 		    // 读取名字
    		while (record >> word)  	  // 读取电话号码
        {
    		  	info.phones.push_back(word); // 保持它们
        }

    		people.push_back(info); 		// 将此记录追加到people末尾
  	}

    ostringstream os;
  	for (const auto &entry : people) // 对people中每一项
    {
    	  ostringstream formatted, badNums; // 每个循环步创建的对象
        for (const auto &nums : entry.phones) // 对每个数
        {
            if (!valid(nums))
            {
                badNums << " " << nums; // 将数的字符串形式存入badNums
            }
            else
            {
              // 将格式化的字符串“写入”formatted
              formatted << " " << format(nums);
            }
        }

        if (badNums.str().empty()) // 没有错误的数
        {
            os << entry.name << " " << formatted.str() << endl; // 打印名字和格式化的数
        }
        else // 否则，打印名字和错误的数
        {
            cerr << "input error: " << entry.name << " invalid number(s) " << badNums.str() << endl;
        }
    }
    cout << os.str() << endl;

    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include "Sales_data.h"
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<Sales_data> sds;
    Sales_data sd;
    while (read(in, sd))
    {
        sds.push_back(sd);
    }

    sort(sds.begin(), sds.end(), compareIsbn);

    for (const auto &s : sds)
    {
        print(cout, s);
        cout << endl;
    }
    return 0;
}
#include <iostream>
#include <fstream>
#include <utility>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<pair<string, int>> data; // pair的vector
    string s;
    int v;
    while (in >> s && in >> v)  // 读取一个字符串和一个整数
    {
        data.push_back({s, v});
    }

  	for (const auto &d : data)  // 打印单词行号
    {
  	   	cout << d.first << " " << d.second << endl;
    }

    return 0;
}
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
	{
		cout << *p << endl;
	}

	return 0;
}
#include <iostream>
using namespace std;

int main()
{
    unsigned int ffCnt = 0, flCnt = 0, fiCnt = 0;
    char ch, prech = '\0';
    cout << "请输入一段文本：" << endl;
    while (cin >> ch)
    {
        bool bl = true;
        if (prech == 'f')
        {
            switch(ch)
            {
                case 'f':
                    ++ffCnt;
                    bl = false;
                    break;
                case 'l':
                    ++flCnt;
                    break;
                case 'i':
                    ++fiCnt;
                    break;
            }
        }
        if (!bl)
        {
            prech = '\0';
        }
        else
        {
            prech = ch;
        }
    }
    cout << "ff的数量是：" << ffCnt << endl;
    cout << "fl的数量是：" << flCnt << endl;
    cout << "fi的数量是：" << fiCnt << endl;
    return 0;
}
#include <iostream>
#include "Sales_data.h"
using namespace std;

int main()
{
    Sales_data total(cin); 							// 淇濆瓨褰撳墠姹傚拰缁撴灉鐨勫彉閲?
    if ( cin )
    { 					// 璇诲叆绗竴绗斾氦鏄?
        Sales_data trans(cin); 						// 淇濆瓨涓嬩竴鏉′氦鏄撴暟鎹殑鍙橀噺
        do
        { 				// 璇诲叆鍓╀綑鐨勪氦鏄?
            if (total.isbn() == trans.isbn()) 	// 妫€鏌sbn
            {
                total.combine(trans); 			// 鏇存柊鍙橀噺total褰撳墠鐨勫€?
            }
            else
            {
                print(cout, total) << endl; 	// 杈撳嚭缁撴灉
                total = trans; 					// 澶勭悊涓嬩竴鏈功
            }
        } while( read(cin, trans) );
        print(cout, total) << endl; 			// 杈撳嚭鏈€鍚庝竴鏉′氦鏄?
    }
    else
    { 									// 娌℃湁杈撳叆浠讳綍淇℃伅
        cerr << "No data?!" << endl; 			// 閫氱煡鐢ㄦ埛
    }

    return 0;
}
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

using namespace std;

struct PersonInfo {
  string name;
  vector<string> phones;
};

string format(const string &s) { return s; }

bool valid(const string &s)
{
	// 如何验证电话号码将在第17章介绍，现在简单返回trure
	return true;
}

int main(int argc, char *argv[])
{
	string line, word; 				    // 分别保存来自输入的一行和单词
	vector<PersonInfo> people; 		// 保存来自输入的所有记录
	istringstream record;

  if (argc != 2) {
    cerr << "请给出文件名" << endl;
    return -1;
  }
  ifstream in(argv[1]);
  if (!in) {
    cerr << "无法打开输入文件" << endl;
    return -1;
  }

	while (getline(in, line)) {
		PersonInfo info; 			      // 创建一个保存此记录数据的对象
		record.clear();           // 重复使用字符串流时，每次都要调用clear
		record.str(line);	          // 将记录绑定到刚读入的行
		record >> info.name; 		    // 读取名字
		while (record >> word)  	  // 读取电话号码
			info.phones.push_back(word); // 保持它们

		people.push_back(info); 		// 将此记录追加到people末尾
	}

  ostringstream os;
	for (const auto &entry : people) { // 对people中每一项
	  ostringstream formatted, badNums; // 每个循环步创建的对象
    for (const auto &nums : entry.phones) { // 对每个数
      if (!valid(nums)) {
        badNums << " " << nums; // 将数的字符串形式存入badNums
      } else
        // 将格式化的字符串“写入”formatted
        formatted << " " << format(nums);
      }
      if (badNums.str().empty()) // 没有错误的数
        os << entry.name << " " // 打印名字
          << formatted.str() << endl; // 和格式化的数
      else // 否则，打印名字和错误的数
        cerr << "input error: " << entry.name
          << " invalid number(s) " << badNums.str() << endl;
  }
  cout << os.str() << endl;

  return 0;
}
#include <iostream>
#include <vector>
#include <list>
using namespace std;


int main()
{
    list<int> ilist = {1, 2, 3, 4, 5, 6, 7};
    vector<int> ivec = {7, 6, 5, 4, 3, 2, 1};

    // 容器类型不同，不能使用拷贝初始化
    // vector<double> ivec(ilist);
    // 元素类型相容，因此可采用范围初始化
    vector<double> dvec(ilist.begin(), ilist.end());

    // 容器类型不同，不能使用拷贝初始化
    // vector<double> dvec1(ivec);
    // 元素类型相容，因此可采用范围初始化
    vector<double> dvec1(ivec.begin(), ivec.end());

    cout << dvec.capacity() << " " << dvec.size() << " " << dvec[0] << " " << dvec[dvec.size()-1]  << endl;
    cout << dvec1.capacity() << " " << dvec1.size() << " " << dvec1[0] << " " << dvec1[dvec1.size()-1]  << endl;

    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

inline void output_words(vector<string>::iterator beg, vector<string>::iterator end)
{
    for (auto iter = beg; iter != end; iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;
}

bool five_or_more(const string &s1)
{
    return s1.size() >= 5;
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<string> words;
    string word;
    while (in >> word)
    {
        words.push_back(word);
    }
    output_words(words.begin(), words.end());

    auto iter = partition(words.begin(), words.end(), five_or_more);
    output_words(words.begin(), iter);
    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

struct X
{
    X() { cout << "构造函数 X()" << endl; }
    X(const X&) { cout << "拷贝构造函数 X(const X&)" << endl; }
    X& operator=(const X &rhs) { cout << "拷贝赋值运算符 =(const X&)" << endl; return *this; }
    ~X() { cout << "析构函数 ~X()" << endl; }
};

void f1(X x)
{
}

void f2(X &x)
{
}

int main(int argc, char **argv)
{
    cout << "局部变量：" << endl;
    X x;
    cout << endl;

    cout << "非引用参数传递：" << endl;
    f1(x);
    cout << endl;

    cout << "引用参数传递：" << endl;
    f2(x);
    cout << endl;

    cout << "动态分配：" << endl;
    X *px = new X;
    cout << endl;

    cout << "添加到容器中：" << endl;
    vector<X> vx;
    vx.push_back(x);
    cout << endl;

    cout << "释放动态分配对象：" << endl;
    delete px;
    cout << endl;

    cout << "间接初始化和赋值：" << endl;
    X y = x;
    y = x;
    cout << endl;

    cout << "程序结束：" << endl;
    return 0;
}
#include <iostream>
using namespace std;

void a(int);    //浼犲€煎弬鏁?
void b(int&);   //浼犲紩鐢ㄥ弬鏁?

int main()
{
    int s = 0, t = 10;
    a(s);
    cout << s << endl;
    b(t);
    cout << t << endl;
    return 0;
}

void a(int i)
{
    ++i;
    cout << i << endl;
}

void b(int& j)
{
    ++j;
    cout << j << endl;
}
#include <iostream>

int main()
{
    for (int i = 10; i >= 0; i--)
    {
        std::cout << i << " ";
    }
    std::cout << std::endl;
    return 0;
}
#include <iostream>

int main()
{
    std::cout << "请输入两个数";
    std::cout << std::endl;
    int v1, v2;
    std::cin >> v1 >> v2;
    if (v1 > v2)	// 由大至小打印
    {
        for (; v1 >= v2; v1--)
        {
            std::cout << v1 << " ";
        }
    }
    else			// 由小至大打印
    {
        for (; v1 <= v2; v1++)
        {
            std::cout << v1 << " ";
        }
    }
    std::cout << std::endl;
    return 0;
}
#include <iostream>

int main()
{
    int sum = 0;
    for (int i = 50; i <= 100; i++)
    {
        sum += i;
    }
    std::cout << "50到100之间的整数之和为" << sum << std::endl;
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    //定义3个字符串变量，分别表示：
    //当前操作的字符串、前一个字符串、当前出现次数最多的字符串
    string currString, preString = "", maxString;
    //定义2个整型变量，分别表示：
    //当前连续出现的字符串数量、当前出现次数最多的字符串数量
    int currCnt = 1, maxCnt = 0;
    while (cin >> currString)    //检查每个字符串
    {
        if (currString == preString) //如果当前字符串与前一个字符串一致，更新状态
        {
            ++currCnt;
            if (currCnt > maxCnt)
            {
                maxCnt = currCnt;
                maxString = currString;
            }
        }
        else //如果当前字符串与前一个字符串不一致，重置currCnt
        {
            currCnt = 1;
        }
        preString = currString; //更新preString以便于下一次循环使用
    }

    if (maxCnt > 1)
    {
        cout << "出现最多的字符串是：" << maxString << "，次数是：" << maxCnt << endl;
    }
    else
    {
        cout << "每个字符串都只出现了一次" << endl;
    }
    return 0;
}
#include <iostream>
#include <vector>
#include <list>
using namespace std;

int main()
{
    list<char *> slist = {"hello", "world", "!"};
    vector<string> svec;

    // 容器类型不同，不能直接赋值
    // svec = slist;
    // 元素类型相容，可以采用范围赋值
    svec.assign(slist.begin(), slist.end());

    cout << svec.capacity() << " " << svec.size() << " " << svec[0] << " " << svec[svec.size()-1]  << endl;
    return 0;
}
#include <iostream>
using namespace std;

int main(int argc, char *argv[])
{
    auto sum = [] (int a, int b) { return a + b; };
    cout << sum(1, 1) << endl;
    return 0;
}
#include <iostream>
#include <map>
#include <utility>
#include <string>
#include <algorithm>
using namespace std;

void add_family(map<string, vector<pair<string, string>>> &families, const string &family)
{
    families[family];
}

void add_child(map<string, vector<pair<string, string>>> &families,
               const string &family, const string &child, const string &birthday)
{
    families[family].push_back({child, birthday});
}

int main(int argc, char *argv[])
{
    map<string, vector<pair<string, string>>> families;

    add_family(families, "张");
    add_child(families, "张", "强", "1970-1-1");
    add_child(families, "张", "刚", "1980-1-1");
    add_child(families, "王", "五", "1990-1-1");
    add_family(families, "王");

    for (auto f : families)
    {
        cout << f.first << "家的孩子：";
        for (auto c : f.second)
        {
            cout << c.first << "(生日" << c.second << "), ";
        }
        cout << endl;
    }

    return 0;
}
#include <iostream>
#include <memory>
using namespace std;

struct destination {};
struct connection {};

connection connect(destination *pd)
{
    cout << "打开连接" << endl;
    return connection();
}

void disconnect(connection c)
{
    cout << "关闭连接" << endl;
}

// 未使用shared_ptr的版本
void f(destination &d)
{
    cout << "直接管理connect" << endl;
    connection c = connect(&d);
    // 忘记调用disconnect关闭连接
    cout << endl;
}

void end_connection(connection *p)
{
    disconnect(*p);
}

// 使用shared_ptr的版本
void f1(destination &d)
{
    cout << "用shared_ptr管理connect" << endl;
    connection c = connect(&d);
    shared_ptr<connection> p(&c, end_connection);
    // 忘记调用disconnect关闭连接
    cout << endl;
}

int main(int argc, char **argv)
{
    destination d;
    f(d);
    f1(d);
  	return 0;
}
#include <iostream>
using std::cout;
using std::cin;
using std::endl;

#include <string>
using std::string;

#include "tScreen.h"

int main()
{
    Screen<5,3> myScreen;
    myScreen.display(cout);
    // 将光标移动到特定位置，并设置其内容
    myScreen.move(4,0).set('#');

    Screen<5,5> nextScreen('X');
    nextScreen.move(4,0).set('#').display(cout);
    cout << "\n";
    nextScreen.display(cout);
    cout << endl;

    const Screen<5,3> blank;
    myScreen.set('#').display(cout);  // 调用非const版本
    cout << endl;
    blank.display(cout);              // 调用const版本
    cout << endl;

    myScreen.clear('Z').display(cout); cout << endl;
    myScreen.move(4,0);
    myScreen.set('#');
    myScreen.display(cout); cout << endl;
    myScreen.clear('Z').display(cout); cout << endl;

    // 由于temp类型是Screen<5,3>而非Screen<5,3>&
    Screen<5,3> temp = myScreen.move(4,0); // 则返回值被拷贝
    temp.set('#'); // 改变temp就不会影响myScreen
    myScreen.display(cout);
    cout << endl;

    cout << endl;
    cin >> myScreen;
    cout << myScreen << endl << nextScreen << endl << temp << endl;

    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> vInt;		//元素类型为int的vector对象
    int i;					//记录用户的输入值
    char cont = 'y';			//与用户交互，决定是否继续输入
    while (cin >> i)
    {
        vInt.push_back(i);	//向vector对象中添加元素
        cout << "您要继续吗（y or n）？ " << endl;
        cin >> cont;
        if (cont != 'y' && cont != 'Y')
        {
            break;
        }
    }
    for (auto mem : vInt)	//使用范围for循环语句遍历vInt中的每个元素
    {
        cout << mem << " ";
    }
    cout << endl;
    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> ivec = {1, 2, 3, 4, 5, 6, 7};
    vector<int> ivec1 = {1, 2, 3, 4, 5, 6, 7};
    vector<int> ivec2 = {1, 2, 3, 4, 5};
    vector<int> ivec3 = {1, 2, 3, 4, 5, 6, 8};
    vector<int> ivec4 = {1, 2, 3, 4, 5, 7, 6};

    cout << (ivec == ivec1) << endl;
    cout << (ivec == ivec2) << endl;
    cout << (ivec == ivec3) << endl;
    cout << (ivec == ivec4) << endl;
    ivec1.push_back(8);
    ivec1.pop_back();
    cout << ivec1.capacity() << " " << ivec1.size() << endl;
    cout << (ivec == ivec1) << endl;

    return 0;
}
#include <iostream>
using namespace std;

void add(int a)
{
    auto sum = [a] (int b) { return a + b; };
    cout << sum(1) << endl;
}

int main(int argc, char *argv[])
{
    add(1);
    add(2);
    return 0;
}
#include <iostream>
#include <memory>
using namespace std;

struct destination {};
struct connection {};

connection connect(destination *pd)
{
    cout << "打开连接" << endl;
    return connection();
}

void disconnect(connection c)
{
    cout << "关闭连接" << endl;
}

// 未使用shared_ptr的版本
void f(destination &d)
{
    cout << "直接管理connect" << endl;
    connection c = connect(&d);
    // 忘记调用disconnect关闭连接
    cout << endl;
}

// 使用shared_ptr的版本
void f1(destination &d)
{
    cout << "用shared_ptr管理connect" << endl;
    connection c = connect(&d);
    shared_ptr<connection> p(&c, [](connection *p) { disconnect(*p); });
    // 忘记调用disconnect关闭连接
    cout << endl;
}

int main(int argc, char **argv)
{
    destination d;
    f(d);
    f1(d);
  	return 0;
}
锘?include <iostream>
#include <string>
#include <regex>
using namespace std;

int main()
{
    // 鏌ユ壘涓嶅湪瀛楃c涔嬪悗鐨勫瓧绗︿覆ei
    string pattern("[^c]ei");
    // 鎴戜滑闇€瑕佸寘鍚玴attern鐨勬暣涓崟璇?
    pattern = "[[:alpha:]]*" + pattern + "[[:alpha:]]*";
    regex r(pattern); 	// 鏋勯€犱竴涓敤浜庢煡鎵炬ā寮忕殑regex
    smatch results; 		// 瀹氫箟涓€涓璞′繚瀛樻悳绱㈢粨鏋?
    // 瀹氫箟涓€涓猻tring淇濆瓨涓庢ā寮忓尮閰嶅拰涓嶅尮閰嶇殑鏂囨湰
    string test_str;
    while (1)
    {
    		cout << "Enter a word, or q to quit:";
        cin >> test_str;
        if (test_str == "q")
        {
            break;
        }

        // 鐢╮鍦╰est_str涓煡鎵句笌pattern鍖归厤鐨勫瓙涓?
        if (regex_search(test_str, results, r)) 	// 濡傛灉鏈夊尮閰嶅瓙涓?
        {
            cout << results.str() << endl; 		// 鎵撳嵃鍖归厤鐨勫崟璇?
        }
    }

  	return 0;
}
#include <iostream>
#include <vector>
#include <string>
using namespace std;

int main()
{
    vector<string> vString;		//元素类型为string的vector对象
    string s;					//记录用户的输入值
    char cont = 'y';			//与用户交互，决定是否继续输入
    while (cin >> s)
    {
        vString.push_back(s);	//向vector对象中添加元素
        cout << "您要继续吗（y or n）？ " << endl;
        cin >> cont;
        if(cont != 'y' && cont != 'Y')
        {
            break;
        }
    }
    for (auto mem : vString)	//使用范围for循环语句遍历vString中的每个元素
    {
        cout << mem << " ";
    }
    cout << endl;
    return 0;
}
#include <iostream>
#include <vector>
#include <string>
using namespace std;

int main()
{
    vector<int> v1;
    vector<int> v2(10);
    vector<int> v3(10, 42);
    vector<int> v4{10};
    vector<int> v5{10, 42};
    vector<string> v6{10};
    vector<string> v7{10, "hi"};

    cout << "v1的元素个数是：" << v1.size() << endl;
    if (v1.size() > 0)       //当vector含有元素时逐个输出
    {
        cout << "v1的元素分别是：" << endl;
        for(auto e : v1)    //使用范围for语句遍历每一个元素
        {
            cout << e << " ";
        }
        cout << endl;
    }

    cout << "v2的元素个数是：" << v2.size() << endl;
    if (v2.size() > 0)       //当vector含有元素时逐个输出
    {
        cout << "v2的元素分别是：" << endl;
        for(auto e : v2)    //使用范围for语句遍历每一个元素
        {
            cout << e << " ";
        }
        cout << endl;
    }

    cout << "v3的元素个数是：" << v3.size() << endl;
    if (v3.size() > 0)       //当vector含有元素时逐个输出
    {
        cout << "v3的元素分别是：" << endl;
        for(auto e : v3)    //使用范围for语句遍历每一个元素
        {
            cout << e << " ";
        }
        cout << endl;
    }

    cout << "v4的元素个数是：" << v4.size() << endl;
    if (v4.size() > 0)       //当vector含有元素时逐个输出
    {
        cout << "v4的元素分别是：" << endl;
        for(auto e : v4)    //使用范围for语句遍历每一个元素
        {
            cout << e << " ";
        }
        cout << endl;
    }

    cout << "v5的元素个数是：" << v5.size() << endl;
    if (v5.size() > 0)       //当vector含有元素时逐个输出
    {
        cout << "v5的元素分别是：" << endl;
        for(auto e : v5)    //使用范围for语句遍历每一个元素
        {
            cout << e << " ";
        }
        cout << endl;
    }

    cout << "v6的元素个数是：" << v6.size() << endl;
    if (v6.size() > 0)       //当vector含有元素时逐个输出
    {
        cout << "v6的元素分别是：" << endl;
        for(auto e : v6)    //使用范围for语句遍历每一个元素
        {
            cout << e << " ";
        }
        cout << endl;
    }

    cout << "v7的元素个数是：" << v7.size() << endl;
    if (v7.size() > 0)       //当vector含有元素时逐个输出
    {
        cout << "v7的元素分别是：" << endl;
        for(auto e : v7)    //使用范围for语句遍历每一个元素
        {
            cout << e << " ";
        }
        cout << endl;
    }

    return 0;
}
#include <iostream>
#include <vector>
#include <list>
using namespace std;

bool l_v_equal(vector<int> &ivec, list<int> &ilist)
{
    // 比较list和vector元素个数
    if (ilist.size() != ivec.size())
    {
        return false;
    }

    auto lb = ilist.cbegin();   // list首元素
    auto le = ilist.cend();     // list尾后位置
    auto vb = ivec.cbegin();    // vector首元素
    for (; lb != le; lb++, vb++)
    {
        if (*lb != *vb)         // 元素不等，容器不等
        {
            return false;
        }
    }
    return true;                // 容器相等
}

int main()
{
    vector<int> ivec = {1, 2, 3, 4, 5, 6, 7};
    list<int> ilist = {1, 2, 3, 4, 5, 6, 7};
    list<int> ilist1 = {1, 2, 3, 4, 5};
    list<int> ilist2 = {1, 2, 3, 4, 5, 6, 8};
    list<int> ilist3 = {1, 2, 3, 4, 5, 7, 6};

    cout << l_v_equal(ivec, ilist) << endl;
    cout << l_v_equal(ivec, ilist1) << endl;
    cout << l_v_equal(ivec, ilist2) << endl;
    cout << l_v_equal(ivec, ilist3) << endl;

    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
#include "make_plural.h"
using namespace std;

inline void output_words(vector<string> &words)
{
    for (auto iter = words.begin(); iter != words.end(); iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;
}

void elimDups(vector<string> &words)
{
    sort(words.begin(), words.end());
    auto end_unique = unique(words.begin(), words.end());
    words.erase(end_unique, words.end());
}

void biggies(vector<string> &words, vector<string>::size_type sz)
{
    elimDups(words); // 将words按字典序排序，删除重复单词
    // 按长度排序，长度相同的单词维持字典序
    stable_sort(words.begin(), words.end(),
          [](const string &a, const string &b) { return a.size() < b.size();});
    // 获取一个迭代器，指向第一个满足size()>= sz的元素
    auto wc = find_if(words.begin(), words.end(),
          [sz](const string &a) { return a.size() >= sz; });
    // 计算满足size >= sz的元素的数目
    auto count = words.end() - wc;
    cout << count << " " << make_plural(count, "word", "s") << " of length " << sz << " or longer" << endl;
    // 打印长度大于等于给定值的单词，每个单词后面接一个空格
    for_each(wc, words.end(),
         [](const string &s) {cout << s << " ";});
    cout << endl;
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<string> words;
    string word;
    while (in >> word)
    {
        words.push_back(word);
    }

    biggies(words, 4);
    return 0;
}
#include "Vec.h"

#include <string>
using std::string;

#include <iostream>
using std::cin; using std::cout; using std::endl;
using std::istream;

void print(const Vec<string> &svec)
{
	for (auto it : svec)
	{
		cout << it << " " ;
	}
	cout <<endl;
}

Vec<string> getVec(istream &is)
{
	Vec<string> svec;
	string s;
	while (is >> s)
	{
		svec.push_back(s);
	}
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
#include <iostream>

int main()
{
    int sum = 0, value = 0;
    std::cout << "请输入一些数，按Ctrl+Z表示结束" << std::endl;
    for (; std::cin >> value;)
    {
        sum += value;
    }
    std::cout << "读入的数之和为" << sum << std::endl;
    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> v1 = {0, 1, 1, 2};
    vector<int> v2 = {0, 1, 1, 2, 3, 5, 8};
    vector<int> v3 = {3, 5, 8};
    vector<int> v4 = {3, 5, 0, 9, 2, 7};

    auto it1 = v1.cbegin(); //定义v1的迭代器
    auto it2 = v2.cbegin(); //定义v2的迭代器
    auto it3 = v3.cbegin(); //定义v3的迭代器
    auto it4 = v4.cbegin(); //定义v4的迭代器
    //设定循环条件：v1和v2都尚未检查完
    while (it1 != v1.cend() && it2 != v2.cend())
    {
        //如果当前位置的两个元素不相等，则肯定没有前缀关系，退出循环
        if (*it1 != *it2)
        {
            cout << "v1和v2之间不存在前缀关系" << endl;
            break;
        }
        ++it1;  //迭代器移动到下一个元素
        ++it2;  //迭代器移动到下一个元素
    }
    if (it1 == v1.cend())    //如果v1较短
    {
        cout << "v1是v2的前缀" << endl;
    }
    if (it2 == v2.cend())    //如果v2较短
    {
        cout << "v2是v1的前缀" << endl;
    }
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

bool HasUpper(const string& str)	//鍒ゆ柇瀛楃涓叉槸鍚﹀惈鏈夊ぇ鍐欏瓧姣?
{
    for (auto c : str)
    {
        if (isupper(c))
        {
            return true;
        }
    }
    return false;
}

void ChangeToLower(string& str)	//鎶婂瓧绗︿覆涓殑鎵€鏈夊ぇ鍐欏瓧姣嶈浆鎴愬皬鍐?
{
    for (auto &c : str)
    {
        c = tolower(c);
    }
}

int main()
{
    cout << "璇疯緭鍏ヤ竴涓瓧绗︿覆锛? << endl;
    string str;
    cin >> str;
    if (HasUpper(str))
    {
        ChangeToLower(str);
        cout << "杞崲鍚庣殑瀛楃涓叉槸锛? << str << endl;
    }
    else
    {
        cout << "璇ュ瓧绗︿覆涓嶅惈澶у啓瀛楁瘝锛屾棤闇€杞崲銆? << endl;
    }
    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include "Sales_data.h"
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<Sales_data> sds;
    Sales_data sd;
    while (read(in, sd))
    {
        sds.push_back(sd);
    }

    sort(sds.begin(), sds.end(),
         [](const Sales_data &lhs, const Sales_data &rhs) { return lhs.isbn() < rhs.isbn(); });

    for (const auto &s : sds)
    {
        print(cout, s);
        cout << endl;
    }
    return 0;
}
#include <iostream>
using namespace std;

class numbered
{
private:
    static int seq;
public:
    numbered () { mysn = seq++; }
    //13.15
    //numbered (numbered &n) { mysn = seq++; }
    int mysn;
};

int numbered::seq = 0;

//13.16
//void f(const numbered &s)
void f(numbered s)
{
    cout << s.mysn << endl;
}

int main(int argc, char **argv)
{
    numbered a, b = a, c = b;
    f(a);
    f(b);
    f(c);
    return 0;
}
锘?include <iostream>
#include <string>
#include <regex>
using namespace std;

int main()
{
    // 鏌ユ壘涓嶅湪瀛楃c涔嬪悗鐨勫瓧绗︿覆ei
    string pattern("[^c]ei");
    // 鎴戜滑闇€瑕佸寘鍚玴attern鐨勬暣涓崟璇?
  	pattern = "[[:alpha:]]*" + pattern + "[[:alpha:]]*";
    regex r(pattern, regex::icase); 	// 鏋勯€犱竴涓敤浜庢煡鎵炬ā寮忕殑regex
    smatch results; 		// 瀹氫箟涓€涓璞′繚瀛樻悳绱㈢粨鏋?
    // 瀹氫箟涓€涓猻tring淇濆瓨涓庢ā寮忓尮閰嶅拰涓嶅尮閰嶇殑鏂囨湰
    string line;
    while (1)
    {
    		cout << "Enter a word, or q to quit:";
    		getline(cin, line);
        if (line == "q")
        {
            break;
        }

    		// 瀹冨皢鍙嶅璋冪敤 regex_search 鏉ュ鎵炬枃浠朵腑鐨勬墍鏈夊尮閰?
    		for (sregex_iterator it(line.begin(), line.end(), r), end_it; it != end_it; ++it)
        {
    		  	cout << it->str() << endl; // 鍖归厤鐨勫崟璇?
        }
    }

  	return 0;
}
#include <iostream>
#include <vector>
#include <string>
using namespace std;

int main()
{
    vector<string> vString;		//元素类型为string的vector对象
    string s;					//记录用户的输入值
    char cont = 'y';			//与用户交互，决定是否继续输入
    cout << "请输入第一个词：" << endl;
    while (cin >> s)
    {
        vString.push_back(s);	//向vector对象中添加元素
        cout << "您要继续吗（y or n）？ " << endl;
        cin >> cont;
        if(cont != 'y' && cont != 'Y')
        {
            break;
        }
        cout << "请输入下一个词：" << endl;
    }
    cout << "转换后的结果是：" << endl;
    for (auto &mem : vString)	//使用范围for循环语句遍历vString中的每个元素
    {
        for (auto &c : mem)      //使用范围for循环语句遍历mem中的每个字符
        {
            c = toupper(c);     //改写为大写字母形式
        }
        cout << mem << endl;
    }
    return 0;
}
namespace Exercise
{
    int ivar = 0;
    double dvar = 0;
    const int limit = 1000;
}

int ivar = 0;
// 浣嶇疆1锛氭彃鍏sing澹版槑
using Exercise::ivar;  // compile error: ivar is redefined.
using Exercise::dvar;
using Exercise::limit;

int main()
{
    // 浣嶇疆2

    double dvar = 3.1416;  // local dvar.
    int iobj = limit + 1;  // Exercise::limit;
    ++ivar;  // ambiguous.
    ++::ivar;  // ambiguous.
    return 0;
}
namespace Exercise
{
    int ivar = 0;
    double dvar = 0;
    const int limit = 1000;
}

int ivar = 0;
// 浣嶇疆1

int main()
{
    // 浣嶇疆2锛氭彃鍏sing澹版槑
    using Exercise::ivar;
    using Exercise::dvar;
    using Exercise::limit;

    double dvar = 3.1416;  // compile error: redeclaration.
    int iobj = limit + 1;  // Exercise::limit
    ++ivar;  // Exercise::ivar
    ++::ivar;  // global ivar
    return 0;
}
namespace Exercise
{
    int ivar = 0;
    double dvar = 0;
    const int limit = 1000;
}

int ivar = 0;
// 浣嶇疆1锛氭彃鍏sing鎸囩ず
using namespace Exercise;

int main()
{
    // 浣嶇疆2

    double dvar = 3.1416;  // Exercise::dvar
    int iobj = limit + 1;  // Exercise::limit
    ++ivar;  // ambiguous
    ++::ivar;  // ambiguous
    return 0;
}
namespace Exercise
{
    int ivar = 0;
    double dvar = 0;
    const int limit = 1000;
}

int ivar = 0;
// 浣嶇疆1

int main()
{
    // 浣嶇疆2锛氭彃鍏sing鎸囩ず
    using namespace Exercise;

    double dvar = 3.1416;  // Exercise::dvar
    int iobj = limit + 1;  // Exercise::limit
    ++ivar;  // ambiguous
    ++::ivar;  // ambiguous
    return 0;
}
#include <iostream>
#include <deque>
using namespace std;

int main()
{
    deque<string> sd;     // string的deque
    string word;
    while (cin >> word)   // 读取字符串，直至遇到文件结束符
    {
        sd.push_back(word);
    }

    // 用cbegin()获取deque首元素迭代器，遍历deque中所有元素
    for (auto si = sd.cbegin(); si != sd.cend(); si++)
    {
        cout << *si << endl;
    }

    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
#include "make_plural.h"
using namespace std;

void elimDups(vector<string> &words)
{
    sort(words.begin(), words.end());
    auto end_unique = unique(words.begin(), words.end());
    words.erase(end_unique, words.end());
}

void biggies(vector<string> &words, vector<string>::size_type sz)
{
    elimDups(words); // 将words按字典序排序，删除重复单词
    for_each(words.begin(), words.end(),
         [](const string &s) {cout << s << " ";});
    cout << endl;
    // 获取一个迭代器，指向最后一个满足size()>= sz的元素之后位置
    auto wc = partition(words.begin(), words.end(),
                        [sz](const string &a) { return a.size() >= sz; });
    // 计算满足size >= sz的元素的数目
    auto count = wc - words.begin();
    cout << count << " " << make_plural(count, "word", "s") << " of length " << sz << " or longer" << endl;
    // 打印长度大于等于给定值的单词，每个单词后面接一个空格
    for_each(words.begin(), wc,
         [](const string &s) {cout << s << " ";});
    cout << endl;
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<string> words;
    string word;
    while (in >> word)
    {
        words.push_back(word);
    }

    biggies(words, 4);
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

class Employee
{
private:
    static int sn;

public:
    Employee () { mysn = sn++; }
    Employee (const string &s) { name = s; mysn = sn++; }
    // 为13.19题定义的拷贝构造函数和拷贝赋值运算符
    //  Employee (Employee &e) { name = e.name; mysn = sn++; }
    //  Employee& operator=(Employee &rhs) { name = rhs.name; return *this; }
    const string &get_name() { return name; }
    int get_mysn() { return mysn; }

private:
    string name;
    int mysn;
};

int Employee::sn = 0;

void f(Employee &s)
{
    cout << s.get_name() << ":" << s.get_mysn() << endl;
}

int main(int argc, char **argv)
{
    Employee a("赵"), b = a, c;
    c = b;
    f(a);
    f(b);
    f(c);
    return 0;
}
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>

using namespace std;

int count_empty_string(vector<string> &vs)
{
  auto f = mem_fn(&string::empty);
  return count_if(vs.begin(), vs.end(), f);
}

int main(int argc, char *argv[])
{
  vector<string> vs = { "Hello", "", "world", "", "!" };
  cout << count_empty_string(vs);

  return 0;
}
#include <iostream>

int main()
{
    int i = 5, j = 10;
    int *p = &i;
    std::cout << p << " " << *p << std::endl;
    p = &j;
    std::cout << p << " " << *p << std::endl;
    *p = 20;
    std::cout << p << " " << *p << std::endl;
    j = 30;
    std::cout << p << " " << *p << std::endl;
    return 0;
}
#include <iostream>
#include <list>
using namespace std;

int main()
{
    list<string> sl;     // string的list
    string word;
    while (cin >> word)   // 读取字符串，直至遇到文件结束符
    {
        sl.push_back(word);
    }

    // 用cbegin()获取list首元素迭代器，遍历list中所有元素
    for (auto si = sl.cbegin(); si != sl.cend(); si++)
    {
        cout << *si << endl;
    }

    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
#include "make_plural.h"
using namespace std;

void elimDups(vector<string> &words)
{
    sort(words.begin(), words.end());
    auto end_unique = unique(words.begin(), words.end());
    words.erase(end_unique, words.end());
}

void biggies(vector<string> &words, vector<string>::size_type sz)
{
    elimDups(words); // 将words按字典序排序，删除重复单词
    for_each(words.begin(), words.end(),
         [](const string &s) {cout << s << " ";});
    cout << endl;
    // 获取一个迭代器，指向最后一个满足size()>= sz的元素之后位置
    auto wc = stable_partition(words.begin(), words.end(),
                        [sz](const string &a) { return a.size() >= sz; });
    // 计算满足size >= sz的元素的数目
    auto count = wc - words.begin();
    cout << count << " " << make_plural(count, "word", "s") << " of length " << sz << " or longer" << endl;
    // 打印长度大于等于给定值的单词，每个单词后面接一个空格
    for_each(words.begin(), wc,
         [](const string &s) {cout << s << " ";});
    cout << endl;
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<string> words;
    string word;
    while (in >> word)
    {
        words.push_back(word);
    }

    biggies(words, 4);
    return 0;
}
#include <iostream>
#include "my_StrBlob.h"
using namespace std;

int main(int argc, char **argv)
{
	StrBlob b1;
	{
	    StrBlob b2 = { "a", "an", "the" };
	    b1 = b2;
	    b2.push_back("about");
		cout << b2.size() << endl;
	}
	cout << b1.size() << endl;
	cout << b1.front() << " " << b1.back() << endl;

	const StrBlob b3 = b1;
	cout << b3.front() << " " << b3.back() << endl;

	for (auto it = b1.begin(); neq(it, b1.end()); it.incr())
	{
		cout << it.deref() << endl;
	}

	return 0;
}
#include <iostream>
#include <string>
#include <vector>
using namespace std;

template <typename C>
void print(const C &c)
{
	for (typename C::size_type i = 0; i < c.size(); i++)
    {
		cout << c.at(i) << " " ;
    }
	cout <<endl;
}

int main()
{
	string s = "Hello!";
	print(s);

    vector<int> vi = { 0, 2, 4, 6, 8 };
    print(vi);

	return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include "Sales_data.h"
#include <algorithm>

using namespace std;
using namespace std::placeholders;

bool check_value(Sales_data &sd, double t)
{
  return sd.avg_price() > t;
}

vector<Sales_data>::iterator find_first_high(vector<Sales_data> &vsd, double t)
{
  auto f = bind(check_value, _1, t);

  return find_if(vsd.begin(), vsd.end(), f);
}

int main(int argc, char *argv[])
{
  ifstream in(argv[1]);
  if (!in) {
    cout << "打开输入文件失败！" << endl;
    exit(1);
  }

  vector<Sales_data> vsd;
  Sales_data sd;
  while (read(in, sd))
    vsd.push_back(sd);

  print(cout, *find_first_high(vsd, 25));

  return 0;
}

#include <iostream>
#include <string>
using namespace std;

int main()
{
    do
    {
        cout << "请输入两个字符串：" << endl;
        string str1, str2;
        cin >> str1 >> str2;
        if (str1.size() < str2.size())
        {
            cout << "长度较小的字符串是：" << str1 << endl;
        }
        else if (str1.size() > str2.size())
        {
            cout << "长度较小的字符串是：" << str2 << endl;
        }
        else
        {
            cout << "两个字符串等长" << endl;
        }
    } while (cin);

    return 0;
}
#include <iostream>
//使用using声明使得cout和endl在程序中可见
using std::cout;
using std::endl;

int main()
{
    int sum = 0;
    int i = 50;
    while (i <= 100)
    {
        sum += i;
        i++;
    }
    cout << "50到100之间的整数之和为" << sum << endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<int> vi;
    int val;
    while (in >> val)
    {
        vi.push_back(val);
    }

    cout << "请输入要搜索的整数：";
    cin >> val;

    int c = 0;
    for (auto iter = vi.begin(); iter != vi.end(); iter++)
    {
        if (*iter == val)
        {
            c++;
        }
    }
    cout << "序列中包含" << c << "个" << val;
    return 0;
}
#include <iostream>
//使用using声明使得cout和endl在程序中可见
using std::cout;
using std::endl;

int main()
{
    int i = 10;
    while (i >= 0)
    {
        cout << i << " ";
        i--;
    }
    cout << endl;
    return 0;
}
#include <iostream>
//使用using声明使得cin、cout和endl在程序中可见
using std::cin;
using std::cout;
using std::endl;

int main()
{
    cout << "请输入两个数";
    cout << endl;
    int v1, v2;
    cin >> v1 >> v2;
    if (v1 > v2)	// 由大至小打印
    {
        while (v1 >= v2)
        {
            cout << v1 << " ";
            v1--;
        }
    }
    else				// 由小至大打印
    {
        while (v1 <= v2)
        {
            cout << v1 << " ";
            v1++;
        }
    }
    cout << endl;
    return 0;
}
#include <iostream>
#include <string>
//使用using声明使得以下的名字在程序中可见
using std::cin;
using std::cout;
using std::endl;
using std::istream;
using std::ostream;
using std::string;

class Sales_data
{
    friend istream& operator>>(istream&, Sales_data&);		//友元函数
    friend ostream& operator<<(ostream&, const Sales_data&);//友元函数
    friend bool operator<(const Sales_data&, const Sales_data&);		//友元函数
    friend bool operator==(const Sales_data&, const Sales_data&);		//友元函数
public:		//构造函数的3种形式
    Sales_data() = default;
    Sales_data(const string &book) : bookNo(book) { }
    Sales_data(istream &is) { is >> *this; }
public:
    Sales_data& operator+=(const Sales_data&);
    string isbn() const { return bookNo; }
private:
    string bookNo;     	//书籍编号，隐式初始化为空串
    unsigned units_sold = 0; 	//销售量，显式初始化为0
    double sellingprice = 0.0;	//原始价格，显式初始化为0.0
	double saleprice = 0.0;		//实售价格，显式初始化为0.0
	double discount = 0.0;		//折扣，显式初始化为0.0

};

inline bool compareIsbn(const Sales_data &lhs, const Sales_data &rhs)
{
    return lhs.isbn() == rhs.isbn();
}

Sales_data operator+(const Sales_data&, const Sales_data&);

inline bool operator==(const Sales_data &lhs, const Sales_data &rhs)
{
    return lhs.units_sold == rhs.units_sold &&
           lhs.sellingprice == rhs.sellingprice &&
           lhs.saleprice == rhs.saleprice &&
           lhs.isbn() == rhs.isbn();
}

inline bool operator!=(const Sales_data &lhs, const Sales_data &rhs)
{
    return !(lhs == rhs); 	//基于运算符==给出!=的定义
}

Sales_data& Sales_data::operator+=(const Sales_data& rhs)
{
    units_sold += rhs.units_sold;
    saleprice = (rhs.saleprice * rhs.units_sold + saleprice * units_sold) / (rhs.units_sold + units_sold);
    if (sellingprice != 0)
    {
        discount = saleprice / sellingprice;
    }
    return *this;
}

Sales_data operator+(const Sales_data& lhs, const Sales_data& rhs)
{
    Sales_data ret(lhs);  	//把lhs的内容拷贝到临时变量ret中，这种做法便于运算
    ret += rhs;           	//把rhs的内容加入其中
    return ret;           	//返回ret
}

istream& operator>>(istream& in, Sales_data& s)
{
    in >> s.bookNo >> s.units_sold >> s.sellingprice >> s.saleprice;
    if (in && s.sellingprice != 0)
    {
        s.discount = s.saleprice / s.sellingprice;
    }
    else
    {
        s = Sales_data();  	//输入错误，重置输入的数据
    }
    return in;
}

ostream& operator<<(ostream& out, const Sales_data& s)
{
    out << s.isbn() << " " << s.units_sold << " "
        << s.sellingprice << " " << s.saleprice << " " << s.discount;
    return out;
}

int main()
{
    Sales_data book;
    cout << "请输入销售记录：" << endl;
    while (cin >> book)
    {
        cout << " ISBN、售出本数、原始价格、原始价格、实售价格、折扣为" << book << endl;
    }

    Sales_data trans1, trans2;
    cout << "请输入两条ISBN相同的销售记录："<< endl;
    cin.clear();
    cin >> trans1 >> trans2;
    if (compareIsbn(trans1, trans2))
    {
        cout << "汇总信息：ISBN、售出本数、原始价格、实售价格、折扣为 "	<< trans1 + trans2 << endl;
    }
    else
    {
        cout << "两条销售记录的ISBN不同" << endl;
    }

    Sales_data total, trans;
    cout << "请输入几条ISBN相同的销售记录："<< endl;
    cin.clear();
    if (cin >> total)
    {
        while (cin >> trans)
        {
            if (compareIsbn(total, trans)) // ISBN 相同
            {
                total = total + trans;
            }
            else // ISBN 不同
            {
                cout << "当前书籍ISBN不同" << endl;
                break;
            }
        }
        cout << "有效汇总信息：ISBN、售出本数、原始价格、实售价格、折扣为" << total << endl;
    }
    else
    {
        cout << "没有数据" << endl;
        return -1;
    }

    int num = 1;		//记录当前书籍的销售记录总数
    cout << "请输入若干销售记录："<< endl;
    cin.clear();
    if (cin >> trans1)
    {
        while (cin >> trans2)
        {
            if (compareIsbn(trans1, trans2)) // ISBN 相同
            {
                num++;
            }
            else // ISBN 不同
            {
                cout << trans1.isbn() << "共有" << num << "条销售记录" << endl;
                trans1 = trans2;
                num = 1;
            }
        }
        cout << trans1.isbn() << "共有" << num << "条销售记录" << endl;
    }
    else
    {
        cout << "没有数据" << endl;
        return -1;
    }

    return 0;
}
#include <iostream>
#include <vector>
#include <ctime>
#include <cstdlib>
using namespace std;

int main()
{
    vector<int> vec;
    srand((unsigned) time(NULL));
    cout << "系统自动为向量生成一组元素......" << endl;
    for (int i = 0; i != 10; i++)
    {
        vec.push_back(rand() % 100);
    }
    cout << "生成的向量数据是：" << endl;
    for (auto c : vec)
    {
        cout << c << " ";
    }
    cout << endl;
    cout << "验证添加的括号是否正确：" << endl;
    cout << "*vec.begin()的值是：" << *vec.begin() <<endl;
    cout << "*(vec.begin())的值是：" << *(vec.begin()) << endl;
    cout << "*vec.begin()+1的值是：" << *vec.begin() + 1 <<endl;
    cout << "(*(vec.begin()))+1的值是：" << (*(vec.begin())) + 1 << endl;

    return 0;
}
#include <iostream>
#include <fstream>
#include <string>
#include <list>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    list<string> ls;
    string word;
    while (in >> word)
    {
        ls.push_back(word);
    }

    cout << "请输入要搜索的字符串：";
    cin >> word;
    cout << "序列中包含" << count(ls.begin(), ls.end(), word) << "个" << word;
    return 0;
}
#include <iostream>
#include "my_StrBlob.h"
using namespace std;

int main(int argc, char **argv)
{
	StrBlob b1;
	{
	    StrBlob b2 = { "a", "an", "the" };
	    b1 = b2;
	    b2.push_back("about");
		cout << b2.size() << endl;
	}
	cout << b1.size() << endl;
	cout << b1.front() << " " << b1.back() << endl;

	const StrBlob b3 = b1;
	cout << b3.front() << " " << b3.back() << endl;

	return 0;
}
#include <vector>
using std::vector;

#include <string>
using std::string;

#include <cstring>
using std::strcmp;

#include <iostream>
using std::cout;
using std::endl;

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
// g++ -std=c++11 StrVec.cpp main.cpp
#include "StrVec.h"
#include <iostream>

using namespace std;

int main()
{
    StrVec sv;
    sv.push_back("hello");
    sv.push_back("world");
    for (auto p = sv.begin(); p != sv.end(); ++p)
    {
        cout << (*p) << endl;
    }
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    string currString, preString;
    bool bl = true;
    cout << "请输入一组字符串：" << endl;
    while (cin >> currString)
    {
        if (currString == preString)
        {
            bl = false;
            cout << "连续出现的字符串是：" << currString << endl;
            break;
        }
        preString = currString;
    }

    if (bl)
    {
        cout << "没有连续出现的字符串" << endl;
    }
    return 0;
}
#include <iostream>
#include <list>
#include <deque>
using namespace std;

int main()
{
    list<int> ilist = {1, 2, 3, 4, 5, 6, 7, 8};   // 初始化整数list
    deque<int> odd_d, even_d;

    // 遍历整数list
    for (auto iter = ilist.cbegin(); iter != ilist.cend(); iter++)
    {
        if (*iter & 1)        // 查看最低位，1：奇数，0：偶数
        {
            odd_d.push_back(*iter);
        }
        else
        {
            even_d.push_back(*iter);
        }
    }

    cout << "奇数值有：";
    for (auto iter = odd_d.cbegin(); iter != odd_d.cend(); iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;

    cout << "偶数值有：";
    for (auto iter = even_d.cbegin(); iter != even_d.cend(); iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;

    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
#include "make_plural.h"
using namespace std;

inline void output_words(vector<string> &words)
{
    for (auto iter = words.begin(); iter != words.end(); iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;
}

void biggies(vector<string> &words, vector<string>::size_type sz)
{
    output_words(words);
    // 统计满足size()>= sz的元素的个数
    auto bc = count_if(words.begin(), words.end(),
        [sz](const string &a) { return a.size() >= sz; });
    cout << bc << " " << make_plural(bc, "word", "s") << " of length " << sz << " or longer" << endl;
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<string> words;
    string word;
    while (in >> word)
    {
        words.push_back(word);
    }

    biggies(words, 6);
    return 0;
}
#include <iostream>
#include <fstream>
#include <map>
#include <string>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    map<string, size_t> word_count; // string到count的映射
    string word;
    while (in >> word)
    {
        auto ret = word_count.insert({word, 1});  // 插入单词，次数为1
        if (!ret.second)    // 插入失败，单词已存在
        {
            ++ret.first->second;   // 已有单词的出现次数加1
        }
    }

  	for (const auto &w : word_count) 	// 对map中的每个元素
    {
  	   	cout << w.first << "出现了" << w.second << "次" << endl;
    }

    return 0;
}
#include <iostream>
#include <fstream>
#include "my_StrBlob.h"
using namespace std;

int main(int argc, char **argv)
{
	ifstream in(argv[1]);
	if (!in)
    {
        cout << "无法打开输入文件" << endl;
        return -1;
	}

	StrBlob b;
    string s;
	while (getline(in, s))
    {
        b.push_back(s);
    }

	for (auto it = b.begin(); neq(it, b.end()); it.incr())
    {
		cout << it.deref() << endl;
    }

	return 0;
}
#include <iostream>
using namespace std;

class Base
{
public:
    void pub_mem();
protected:
    int prot_mem;
private:
    char priv_mem;
};

struct Pub_Derv : public Base
{
    int f() { return prot_mem; }
    void memfcn(Base &b)
    {
        b=*this;
        cout<<"Pub_Derv"<<endl;
    }
};

struct Priv_Derv : private Base
{
    int f1() const { return prot_mem; }
    void memfcn(Base &b)
    {
        b=*this;
        cout<<"Priv_Derv"<<endl;
    }
};

struct Prot_Derv : protected Base
{
    int f2() { return prot_mem; }
    void memfcn(Base &b)
    {
        b=*this;
        cout<<"Prot_Derv"<<endl;
    }
};

struct Derived_from_Public : public Pub_Derv
{
    int use_base() { return prot_mem; }
    void memfcn(Base &b)
    {
        b=*this;
        cout<<"Derived_from_Public"<<endl;
    }
};

struct Derived_from_Protected : protected Prot_Derv
{
    int use_base() { return prot_mem; }
    void memfcn(Base &b)
    {
        b=*this;
        cout<<"Derived_from_Protected"<<endl;
    }
};

int main(int argc, const char *argv[])
{
    Pub_Derv d1;
    Priv_Derv d2;
    Prot_Derv d3;
    Derived_from_Public dd1;
   // Derived_from_Private dd2;
    Derived_from_Protected dd3;
    Base base;
    Base *p=new Base;
    p=&d1;              //d1鐨勭被鍨嬫槸Pub_Derv
    //p=&d2;              //d2鐨勭被鍨嬫槸Priv_Derv
    //p=&d3;              //d3鐨勭被鍨嬫槸Prot_Derv
    p=&dd1;             //dd1鐨勭被鍨嬫槸Derived_from_Public
    //p=&dd2;             //dd2鐨勭被鍨嬫槸Derived_from_Private
    //p=&dd3;             //dd3鐨勭被鍨嬫槸Derived_from_Protected

    d1.memfcn(base);
    d2.memfcn(base);
    d3.memfcn(base);
    dd1.memfcn(base);
    //dd2.memfcn(base);
    dd3.memfcn(base);
    return 0;
}
#include <iostream>
#include <string>
#include <vector>
#include <list>
using namespace std;

template <typename C>
void print(const C &c)
{
	for (auto i = c.begin(); i != c.end(); i++)
    {
		cout << *i << " " ;
    }
	cout <<endl;
}

int main()
{
	string s = "Hello!";
	print(s);

    vector<int> vi = { 0, 2, 4, 6, 8 };
    print(vi);

    list<string> ls = { "Hel", "lo", "!" };
    print(ls);

	return 0;
}
锘?include <iostream>
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
	{
		// the area code must be followed by a close parenthesis
		// and followed immediately by the rest of the number or a space
	    return m[3].matched && (m[4].matched == 0 || m[4].str() == " ");
	}
	else
	{
		// then there can't be a close after the area code
		// the delimiters between the other two components must match
		return !m[3].matched && m[4].str() == m[6].str();
	}
}

int main()
{
	// our overall expression has seven subexpressions:
	//    ( ddd ) separator ddd separator dddd
	// subexpressions 1, 3, 4, and 6 are optional;
	// subexpressions 2, 5, and 7 hold the number
	string phone = "(\\()?(\\d{3})(\\))?([-. ])?(\\d{3})([-. ]?)(\\d{4})";
	regex r(phone);  // a regex to find our pattern
	smatch m;        // a match object to hold the results
	string s;        // a string to search

	// read each record from the input file
	while (getline(cin, s))
	{
		// for each matching phone number
		for (sregex_iterator it(s.begin(), s.end(), r), end_it; it != end_it; ++it)
		{
			// check whether the number's formatting is valid
			if (valid(*it))
			{
				cout << "valid: " << it->str() << endl;
			}
			else
			{
				cout << "not valid: " << it->str() << endl;
			}
		}
	}

	return 0;
}#include <iostream>
#include "Sales_item.h"

int main()
{
    Sales_item book;
    std::cout << "请输入销售记录：" << std::endl;
    while (std::cin >> book)
    {
        std::cout << "ISBN、售出本数、销售额和平均售价为 " << book << std::endl;
    }
    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> vInt;
    int iVal;
    cout << "请输入一组数字：" << endl;
    while (cin >> iVal)
    {
        vInt.push_back(iVal);
    }
    if (vInt.size() == 0)
    {
        cout << "没有任何元素" << endl;
        return -1;
    }

    cout << "相邻两项的和依次是：" << endl;
    //利用decltype推断i的类型
    for(decltype(vInt.size()) i = 0; i < vInt.size() - 1; i += 2)
    {
        //求相邻两项的和
        cout << vInt[i] + vInt[i+1] << " ";
        //每行输出5个数字
        if ((i + 2) % 10 == 0)
        {
            cout << endl;
        }
    }
    //如果元素数是奇数，单独处理最后一个元素
    if (vInt.size() % 2 != 0)
    {
        cout << vInt[vInt.size() - 1];
    }

    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> vInt;
    int iVal;
    cout << "请输入一组数字：" << endl;
    while (cin >> iVal)
    {
        vInt.push_back(iVal);
    }
    if (vInt.size() == 0)
    {
        cout << "没有任何元素" << endl;
        return -1;
    }

    cout << "首尾两项的和依次是：" << endl;
    //利用decltype推断i的类型
    for (decltype(vInt.size()) i = 0; i < vInt.size() / 2; i++)
    {
        //求首尾两项的和
        cout << vInt[i] + vInt[vInt.size() - i - 1] << " ";
        //每行输出5个数字
        if ((i + 1) % 5 == 0)
        {
            cout << endl;
        }
    }
    //如果元素数是奇数，单独处理最后一个元素
    if (vInt.size() % 2 != 0)
    {
        cout << vInt[vInt.size() / 2];
    }

    return 0;
}
#include <iostream>
#include <vector>
#include <string>
using namespace std;

int main()
{
    vector<int> v1;
    vector<int> v2(10);
    vector<int> v3(10, 42);
    vector<int> v4{10};
    vector<int> v5{10, 42};
    vector<string> v6{10};
    vector<string> v7{10, "hi"};

    cout << "v1的元素个数是：" << v1.size() << endl;
    if (v1.cbegin() != v1.cend())       //当vector含有元素时逐个输出
    {
        cout << "v1的元素分别是：" << endl;
        for(auto it = v1.cbegin(); it != v1.cend(); it++)//使用范围for语句遍历每一个元素
        {
            cout << *it << " ";
        }
        cout << endl;
    }

    cout << "v2的元素个数是：" << v2.size() << endl;
    if (v2.cbegin() != v2.cend())       //当vector含有元素时逐个输出
    {
        cout << "v2的元素分别是：" << endl;
        for(auto it = v2.cbegin(); it != v2.cend(); it++)//使用范围for语句遍历每一个元素
        {
            cout << *it << " ";
        }
        cout << endl;
    }

    cout << "v3的元素个数是：" << v3.size() << endl;
    if (v3.cbegin() != v3.cend())       //当vector含有元素时逐个输出
    {
        cout << "v3的元素分别是：" << endl;
        for(auto it = v3.cbegin(); it != v3.cend(); it++)//使用范围for语句遍历每一个元素
        {
            cout << *it << " ";
        }
        cout << endl;
    }

    cout << "v4的元素个数是：" << v4.size() << endl;
    if (v4.cbegin() != v4.cend())       //当vector含有元素时逐个输出
    {
        cout << "v4的元素分别是：" << endl;
        for(auto it = v4.cbegin(); it != v4.cend(); it++)//使用范围for语句遍历每一个元素
        {
            cout << *it << " ";
        }
        cout << endl;
    }

    cout << "v5的元素个数是：" << v5.size() << endl;
    if (v5.cbegin() != v5.cend())       //当vector含有元素时逐个输出
    {
        cout << "v5的元素分别是：" << endl;
        for(auto it = v5.cbegin(); it != v5.cend(); it++)//使用范围for语句遍历每一个元素
        {
            cout << *it << " ";
        }
        cout << endl;
    }

    cout << "v6的元素个数是：" << v6.size() << endl;
    if (v6.cbegin() != v6.cend())       //当vector含有元素时逐个输出
    {
        cout << "v6的元素分别是：" << endl;
        for(auto it = v6.cbegin(); it != v6.cend(); it++)//使用范围for语句遍历每一个元素
        {
            cout << *it << " ";
        }
        cout << endl;
    }

    cout << "v7的元素个数是：" << v7.size() << endl;
    if (v7.cbegin() != v7.cend())       //当vector含有元素时逐个输出
    {
        cout << "v7的元素分别是：" << endl;
        for(auto it = v7.cbegin(); it != v7.cend(); it++)//使用范围for语句遍历每一个元素
        {
            cout << *it << " ";
        }
        cout << endl;
    }

    return 0;
}
#include <iostream>
#include <vector>
#include <ctime>
#include <cstdlib>
using namespace std;

int main()
{
    vector<int> vInt;
    const int sz = 10;  //使用sz作为数组的维度
    srand((unsigned) time(NULL)); //生成随机数种子
    //使用普通for循环为数组赋初值
    cout << "数组的初始值是：" << endl;
    for (int i = 0; i != sz; ++i)
    {
        vInt.push_back(rand() % 100);   //生成100以内的随机数
        cout << vInt[i] << " "; //使用下标运算符输出数组内容
    }
    cout << endl;

    //使用范围for循环把数组中的奇数翻倍
    for (auto &val : vInt)
    {
        val = (val % 2 != 0) ? val * 2 : val;   //条件表达式
    }
    //使用范围for循环和迭代器输出数组的当前值
    cout << "调整后的数组值是：" << endl;
    for (auto it = vInt.cbegin(); it != vInt.cend(); ++it)
    {
        cout << *it << " ";
    }
    cout << endl;
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    string currString, preString;
    bool bl = true;
    cout << "请输入一组字符串：" << endl;
    while (cin >> currString)
    {
        if (!isupper(currString[0]))
        {
            continue;
        }

        if (currString == preString)
        {
            bl = false;
            cout << "连续出现的字符串是：" << currString << endl;
            break;
        }
        preString = currString;
    }

    if (bl)
    {
        cout << "没有连续出现的字符串" << endl;
    }
    return 0;
}
#include <iostream>
#include <string>
#include <ctime>
#include <cstdlib>
using namespace std;

int myCompare(const int val, const int *p)
{
    return (val > *p) ? val : *p;
}

int main()
{
    srand((unsigned) time(NULL));
    int a[10];
    for (auto &i : a)
    {
        i = rand() % 100;
    }

    cout << "璇疯緭鍏ヤ竴涓暟锛?;
    int j;
    cin >> j;
    cout << "鎮ㄨ緭鍏ョ殑鏁颁笌鏁扮粍棣栧厓绱犱腑杈冨ぇ鐨勬槸锛? << myCompare(j, a) << endl;
    cout << "鏁扮粍鐨勫叏閮ㄥ厓绱犳槸锛? << endl;
    for (auto i : a)
    {
        cout << i << " ";
    }
    cout << endl;
    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<string> svec;     // string的vector
    string word;
    auto iter = svec.begin(); // 获取vector首位置迭代器
    while (cin >> word)   // 读取字符串，直至遇到文件结束符
    {
        iter = svec.insert(iter, word);
    }

    // 用cbegin()获取vector首元素迭代器，遍历vector中所有元素
    for (auto iter = svec.cbegin(); iter != svec.cend(); iter++)
    {
        cout << *iter << endl;
    }

    return 0;
}
#include <iostream>
#include <algorithm>

using namespace std;

void mutable_lambda(void)
{
  int i = 5;
  auto f = [i] () mutable -> bool{ if (i > 0) { i--; return false;} else return true; };

  for (int j = 0; j < 6; j++)
    cout << f() << " ";
  cout << endl;
}

int main(int argc, char *argv[])
{
  mutable_lambda();

  return 0;
}
#include <cstddef>
using std::size_t;

#include <iostream>
using std::cout;
using std::endl;

#include <string>
using std::string;

#include <memory>
using std::unique_ptr;
using std::shared_ptr;

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

锘?include <iostream>
using std::cin; using std::cout; using std::cerr;
using std::istream; using std::ostream; using std::endl;

#include <sstream>
using std::ostringstream; using std::istringstream;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <regex>
using std::regex; using std::smatch; using std::regex_match;
using std::sregex_iterator;

// members are public by default
struct PersonInfo
{
	string name;
	vector<string> phones;
};

// we'll see how to reformat phone numbers in chapter 17
// for now just return the string we're given
string format(const string &s) { return s; }

bool valid(const smatch& m)
{
	if (m[1].matched)
	{
		// the area code must be followed by a close parenthesis
		// and followed immediately by the rest of the number or a space
	    return m[3].matched && (m[4].matched == 0 || m[4].str() == " ");
	}
	else
	{
		// then there can't be a close after the area code
		// the delimiters between the other two components must match
		return !m[3].matched && m[4].str() == m[6].str();
	}
}

vector<PersonInfo> getData(istream &is)
{
	string phone = "(\\()?(\\d{3})(\\))?([-. ])?(\\d{3})([-. ]?)(\\d{4})";
	regex r(phone);  // a regex to find our pattern
	smatch m;        // a match object to hold the results

	// will hold a line and word from input, respectively
	string line, word;

	// will hold all the records from the input
	vector<PersonInfo> people;

	// read the input a line at a time until end-of-file (or other error)
	while (getline(is, line))
	{
		PersonInfo info;            // object to hold this record's data
	  	istringstream record(line); // bind record to the line we just read
		record >> info.name;        // read the name
		getline(record, line);
		for (sregex_iterator it(line.begin(), line.end(), r), end_it; it != end_it; ++it) // match the phone numbers
		{
			if (valid(*it))			  // and check and store them
			{
				info.phones.push_back("V" + it->str());
			}
			else
			{
				info.phones.push_back("I" + it->str());
			}
		}
		people.push_back(info); // append this record to people
	}

	return people;
}

ostream& process(ostream &os, vector<PersonInfo> people)
{
	for (const auto &entry : people)    // for each entry in people
	{
		ostringstream formatted, badNums; // objects created on each loop
		for (const auto &nums : entry.phones)  // for each number
		{
			if (nums[0] == 'I')
			{
				badNums << " " << nums.substr(1) << endl;  // string in badNums
			}
			else
			{
				// ``writes'' to formatted's string
				formatted << " " << format(nums.substr(1)) << endl;
			}
		}
		if (badNums.str().empty())      // there were no bad numbers
		{
			os << entry.name << endl     // print the name
			   << formatted.str() << endl; // and reformatted numbers
		}
		else                   // otherwise, print the name and bad numbers
		{
			cerr << "input error: " << entry.name
			     << " invalid number(s) " << badNums.str() << endl;
		}
	}

	return os;
}

int main()
{
	process(cout, getData(cin));
	return 0;
}
#include <iostream>
#include "Sales_item.h"

int main()
{
    Sales_item trans1, trans2;
    std::cout << "请输入两条ISBN相同的销售记录：" << std::endl;
    std::cin >> trans1 >> trans2;
    if (compareIsbn(trans1, trans2))
    {
        std::cout << "汇总信息：ISBN、售出本数、销售额和平均售价为 " << trans1 + trans2 << std::endl;
    }
    else
    {
        std::cout << "两条销售记录的ISBN不同" << std::endl;
    }
    return 0;
}
#include <iostream>

int main()
{
    int i = 0;
    int *p1 = nullptr;
    int *p = &i;
    if (p1)	// 检验指针的值（即指针所指对象的地址）
    {
        std::cout<<"p1 pass"<< std::endl;
    }
    if (p)	//检验指针的值（即指针所指对象的地址）
    {
        std::cout<<"p pass"<< std::endl;
    }
    if (*p)	//检验指针所指对象的值
    {
        std::cout<<"i pass"<< std::endl;
    }
    return 0;
}
#include <iostream>
#include <vector>
#include <string>
using namespace std;

int main()
{
    vector<string> text;
    string s;
    //利用getline读取一句话，直接回车产生一个空串，表示段落结束
    while (getline(cin, s))
    {
        text.push_back(s);  //逐个添加到text中
    }
    //利用迭代器遍历全部字符串，遇空串停止循环
    for (auto it = text.begin(); it != text.end() && !it->empty(); it++)
    {
        //利用迭代器遍历当前字符串
        for (auto it2 = it->begin(); it2 != it->end(); it2++)
        {
            *it2 = toupper(*it2);   //利用toupper改写成大写形式
        }
        cout << *it << endl;        //输出当前字符串
    }

    return 0;
}
#include <iostream>
using namespace std;

//璇ュ嚱鏁版棦涓嶄氦鎹㈡寚閽堬紝涔熶笉浜ゆ崲鎸囬拡鎵€鎸囩殑鍐呭
void SwapPointer1(int *p, int *q)
{
    int *temp = p;
    p = q;
    q = temp;
}

//璇ュ嚱鏁版崲鎸囬拡鎵€鎸囩殑鍐呭
void SwapPointer2(int *p, int *q)
{
    int temp = *p;
    *p = *q;
    *q = temp;
}

//璇ュ嚱鏁颁氦鎹㈡寚閽堟湰韬殑鍊硷紝鍗充氦鎹㈡寚閽堟墍鎸囩殑鍐呭瓨鍦板潃
void SwapPointer3(int *&p, int *&q)
{
    int *temp = p;
    p = q;
    q = temp;
}

int main()
{
    int a = 5, b = 10;
    int *p = &a, *q = &b;
    cout << "浜ゆ崲鍓嶏細" << endl;
    cout << "p鐨勫€兼槸锛? << p << "锛宷鐨勫€兼槸锛? << q << endl;
    cout << "p鎵€鎸囩殑鍊兼槸锛? << *p << "锛宷鎵€鎸囩殑鍊兼槸锛? << *q << endl;
    SwapPointer1(p, q);
    cout << "浜ゆ崲鍚庯細" << endl;
    cout << "p鐨勫€兼槸锛? << p << "锛宷鐨勫€兼槸锛? << q << endl;
    cout << "p鎵€鎸囩殑鍊兼槸锛? << *p << "锛宷鎵€鎸囩殑鍊兼槸锛? << *q << endl;

    a = 5, b = 10;
    p = &a, q = &b;
    cout << "浜ゆ崲鍓嶏細" << endl;
    cout << "p鐨勫€兼槸锛? << p << "锛宷鐨勫€兼槸锛? << q << endl;
    cout << "p鎵€鎸囩殑鍊兼槸锛? << *p << "锛宷鎵€鎸囩殑鍊兼槸锛? << *q << endl;
    SwapPointer2(p, q);
    cout << "浜ゆ崲鍚庯細" << endl;
    cout << "p鐨勫€兼槸锛? << p << "锛宷鐨勫€兼槸锛? << q << endl;
    cout << "p鎵€鎸囩殑鍊兼槸锛? << *p << "锛宷鎵€鎸囩殑鍊兼槸锛? << *q << endl;

    a = 5, b = 10;
    p = &a, q = &b;
    cout << "浜ゆ崲鍓嶏細" << endl;
    cout << "p鐨勫€兼槸锛? << p << "锛宷鐨勫€兼槸锛? << q << endl;
    cout << "p鎵€鎸囩殑鍊兼槸锛? << *p << "锛宷鎵€鎸囩殑鍊兼槸锛? << *q << endl;
    SwapPointer3(p, q);
    cout << "浜ゆ崲鍚庯細" << endl;
    cout << "p鐨勫€兼槸锛? << p << "锛宷鐨勫€兼槸锛? << q << endl;
    cout << "p鎵€鎸囩殑鍊兼槸锛? << *p << "锛宷鎵€鎸囩殑鍊兼槸锛? << *q << endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
#include <functional>
#include "make_plural.h"
using namespace std;
using namespace std::placeholders;

inline void output_words(vector<string> &words)
{
    for (auto iter = words.begin(); iter != words.end(); iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;
}

bool check_size(const string &s, string::size_type sz)
{
    return s.size() >= sz;
}

void biggies(vector<string> &words, vector<string>::size_type sz)
{
    output_words(words);
    // 统计满足size()>= sz的元素的个数
    auto bc = count_if(words.begin(), words.end(), bind(check_size, _1, sz));
    cout << bc << " " << make_plural(bc, "word", "s") << " of length " << sz << " or longer" << endl;
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<string> words;
    string word;
    while (in >> word)
    {
        words.push_back(word);
    }

    biggies(words, 6);
    return 0;
}
#include <iostream>
#include "my_StrBlob.h"
using namespace std;

int main(int argc, char **argv)
{
	const StrBlob b = {"Hello", "World", "!"};
	for (auto it = b.begin(); neq(it, b.end()); it.incr())
    {
		cout << it.deref() << endl;
    }
	return 0;
}
#include <iostream>
#include <string>
using namespace std;

class HasPtr
{
public:
    HasPtr(const string &s = string()) : ps(new string(s)), i(0) {}
    HasPtr(const HasPtr &p) : ps(new string(*p.ps)), i(p.i) { }  // 拷贝构造函数
    HasPtr& operator=(const HasPtr&);  // 拷贝赋值运算符
    HasPtr& operator=(const string&);  // 赋予新string
    string& operator*();       // 解引用
    ~HasPtr();
private:
    string *ps;
    int i;
};

HasPtr::~HasPtr()
{
    delete ps; 		// 释放string内存
}

inline HasPtr& HasPtr::operator=(const HasPtr &rhs)
{
    auto newps = new string(*rhs.ps); // 拷贝指针指向的对象
    delete ps;					// 销毁原string
    ps = newps;					// 指向新string
    i = rhs.i; 					// 使用内置的int赋值
    return *this; 				// 返回一个此对象的引用
}

HasPtr& HasPtr::operator=(const string &rhs)
{
    *ps = rhs;
    return *this;
}

string& HasPtr::operator*()
{
    return *ps;
}

int main(int argc, char **argv)
{
    HasPtr h("hi mom!");
    HasPtr h2(h);  // 行为类值，h2、h3和h指向不同string
    HasPtr h3 = h;
    h2 = "hi dad!";
    h3 = "hi son!";
    cout << "h: " << *h << endl;
    cout << "h2: " << *h2 << endl;
    cout << "h3: " << *h3 << endl;
    return 0;
}
#include <string>
using std::string;

#include <fstream>
using std::ifstream;

#include <iostream>
using std::cin; using std::cout; using std::cerr;
using std::endl;

#include <cstdlib>  // for EXIT_FAILURE

#include "dd_TextQuery.h"
#include "make_plural.h"

void runQueries(ifstream &infile)
{
	// infile is an ifstream that is the file we want to query
    TextQuery tq(infile);  // store the file and build the query map
    // iterate with the user: prompt for a word to find and print results
    while (true)
    {
        cout << "enter word to look for, or q to quit: ";
        string s;
        // stop if we hit end-of-file on the input or if a 'q' is entered
        if (!(cin >> s) || s == "q")
        {
            break;
        }
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
    if (argc < 2 || !(infile.open(argv[1]), infile))
    {
        cerr << "No input file!" << endl;
        return EXIT_FAILURE;
    }
	runQueries(infile);

    return 0;
}
锘?include <iostream>
using std::cin; using std::cout; using std::cerr;
using std::istream; using std::ostream; using std::endl;

#include <sstream>
using std::ostringstream; using std::istringstream;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <regex>
using std::regex; using std::smatch; using std::regex_match;
using std::sregex_iterator;

// members are public by default
struct PersonInfo
{
	string name;
	vector<string> phones;
};

// we'll see how to reformat phone numbers in chapter 17
// for now just return the string we're given
string format(const string &s)
{
	return s;
}

bool valid(const smatch& m)
{
	if(m[1].matched)
	{
		// the area code must be followed by a close parenthesis
		// and followed immediately by the rest of the number or a space sequence
	    return m[3].matched && (m[4].matched == 0 || (m[4].str() != "-" && m[4].str() != "."));
	}
	else
	{
		// then there can't be a close after the area code
		// the delimiters between the other two components must match
		return !m[3].matched
		       && ((m[4].str() == "-" && m[6].str() == ".")
					 || (m[4].str() == "." && m[6].str() == ".")
					 || (m[4].str() != "-" && m[4].str() != "."
					 && m[6].str() != "-" && m[6].str() != "."));
	}
}

vector<PersonInfo>
getData(istream &is)
{
	string phone = "(\\()?(\\d{3})(\\))?([-.]|(\\s)*)?(\\d{3})([-.]|(\\s)*)?(\\d{4})";
	regex r(phone);  // a regex to find our pattern
	smatch m;        // a match object to hold the results

	// will hold a line and word from input, respectively
	string line, word;

	// will hold all the records from the input
	vector<PersonInfo> people;

	// read the input a line at a time until end-of-file (or other error)
	while (getline(is, line))
	{
		PersonInfo info;            // object to hold this record's data
	  	istringstream record(line); // bind record to the line we just read
		record >> info.name;        // read the name
		getline(record, line);
		for (sregex_iterator it(line.begin(), line.end(), r), end_it; it != end_it; ++it) // match the phone numbers
		{
			if (valid(*it))			  // and check and store them
			{
				info.phones.push_back("V" + it->str());
			}
			else
			{
				info.phones.push_back("I" + it->str());
			}
		}
		people.push_back(info); // append this record to people
	}

	return people;
}

ostream& process(ostream &os, vector<PersonInfo> people)
{
	for (const auto &entry : people)    // for each entry in people
	{
		ostringstream formatted, badNums; // objects created on each loop
		for (const auto &nums : entry.phones)  // for each number
		{
			if (nums[0] == 'I')
			{
				badNums << " " << nums.substr(1) << endl;  // string in badNums
			}
			else
			{
				// ``writes'' to formatted's string
				formatted << " " << format(nums.substr(1)) << endl;
			}
		}
		if (badNums.str().empty())      // there were no bad numbers
		{
			os << entry.name << endl     // print the name
			   << formatted.str() << endl; // and reformatted numbers
		}
		else                   // otherwise, print the name and bad numbers
		{
			cerr << "input error: " << entry.name
			     << " invalid number(s) " << badNums.str() << endl;
		}
	}

	return os;
}

int main()
{
	process(cout, getData(cin));
	return 0;
}
#include <iostream>
#include "Sales_item.h"

int main()
{
    Sales_item total, trans;
    std::cout << "请输入几条ISBN相同的销售记录：" << std::endl;
    if (std::cin >> total)
    {
        while (std::cin >> trans)
        {
            if (compareIsbn(total, trans)) // ISBN 相同
            {
                total = total + trans;
            }
            else // ISBN 不同
            {
                std::cout << "ISBN不同" << std::endl;
                return -1;
            }
        }
        std::cout << "汇总信息：ISBN、售出本数、销售额和平均售价为 " << total << std::endl;
    }
    else
    {
        std::cout << "没有数据" << std::endl;
        return -1;
    }
    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> iv = {1, 1, 2, 1};  // int的vector
    int some_val = 1;

    vector<int>::iterator iter = iv.begin();
    int org_size = iv.size(), new_ele = 0;  // 原大小和新元素个数

    // 每个循环步都重新计算“mid”，保证正确指向iv原中央元素
    while (iter != (iv.begin() + org_size / 2 + new_ele))
    {
        if (*iter == some_val)
        {
            iter = iv.insert(iter, 2 * some_val); // iter指向新元素
            new_ele++;
            iter++; iter++;  // 将iter推进到旧元素的下一个位置
        }
        else
        {
            iter++;          // 简单推进iter
        }
    }

  // 用begin()获取vector首元素迭代器，遍历vector中所有元素
  for (iter = iv.begin(); iter != iv.end(); iter++)
  {
      cout << *iter << endl;
  }

  return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    string finalgrade;
    int grade;
    cout << "请输入您要检查的成绩：" << endl;
    //确保输入的成绩合法
    while (cin >> grade && grade >= 0 && grade <= 100)
    {
        //使用三层嵌套的条件表达式
        finalgrade = (grade > 90) ? "high pass"
                              : (grade > 75) ? "pass"
                                             : (grade > 60) ? "low pass" : "fail";
        cout << "该成绩所处的档次是：" << finalgrade << endl;
        cout << "请输入您要检查的成绩：" << endl;
    }

    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> iv = {1, 1, 1, 1, 1};  // int的vector
    int some_val = 1;

    vector<int>::iterator iter = iv.begin();
    int org_size = iv.size(), i = 0;  // 原大小

    // 用循环变量控制循环次数
    while (i <= org_size / 2)
    {
        if (*iter == some_val)
        {
            iter = iv.insert(iter, 2 * some_val);  // iter指向新元素
            iter++; iter++;  // 将iter推进到旧元素的下一个位置
        }
        else
        {
            iter++;  // 简单推进iter
        }

        i++;
    }

    // 用begin()获取vector首元素迭代器，遍历vector中所有元素
    for (iter = iv.begin(); iter != iv.end(); iter++)
    {
        cout << *iter << endl;
    }

    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    string finalgrade;
    int grade;
    cout << "请输入您要检查的成绩：" << endl;
    //确保输入的成绩合法
    while (cin >> grade && grade >= 0 && grade <= 100)
    {
        //使用if语句实现
        if (grade > 90)
        {
            finalgrade = "high pass";
        }
        else if (grade > 75)
        {
            finalgrade = "pass";
        }
        else if (grade > 60)
        {
            finalgrade = "low pass";
        }
        else
        {
            finalgrade = "fail";
        }
        cout << "该成绩所处的档次是：" << finalgrade << endl;
        cout << "请输入您要检查的成绩：" << endl;
    }

    return 0;
}
#include <iostream>
#include <vector>
#include <ctime>
#include <cstdlib>
using namespace std;

int main()
{
    vector<int> vInt;
    srand((unsigned) time(NULL));    //生成随机数种子
    for (int i = 0; i < 10; i++)     	//循环10次
    {
        //每次循环生成一个1000以内的随机数并添加到vInt中
        vInt.push_back(rand() % 1000);
    }
    cout << "随机生成的10个数字是：" << endl;
    //利用常量迭代器读取原始数据
    for (auto it = vInt.cbegin(); it != vInt.cend(); it++)
    {
        cout << *it << " ";        //输出当前数字
    }
    cout << endl;
    cout << "翻倍后的10个数字是：" << endl;
    //利用非常量迭代器修改vInt内容并输出
    for (auto it = vInt.begin(); it != vInt.end(); it++)
    {
        *it *= 2;
        cout << *it << " ";        //输出当前数字
    }
    cout << endl;

    return 0;
}
#include <iostream>
using namespace std;

int main()
{
    cout << "请依次输入被除数和除数：" << endl;
    int ival1, ival2;
    cin >> ival1 >> ival2;
    if (ival2 == 0)
    {
        cout << "除数不能为0" << endl;
        return -1;
    }
    cout << "两数相除的结果是：" << ival1 / ival2 << endl;
    return 0;
}
#include <iostream>
using namespace std;

//鍙傛暟鏄父閲忔暣鍨嬫寚閽?
void print1(const int *p)
{
    cout << *p << endl;
}

//鍙傛暟鏈変袱涓紝鍒嗗埆鏄父閲忔暣鍨嬫寚閽堝拰鏁扮粍鐨勫閲?
void print2(const int *p, const int sz)
{
    int i = 0;
    while (i != sz)
    {
        cout << *p++ << endl;
        ++i;
    }
}

//鍙傛暟鏈変袱涓紝鍒嗗埆鏄暟缁勭殑棣栧熬杈圭晫
void print3(const int *b, const int *e)
{
    for (auto q = b; q != e; ++q)
    {
        cout << *q << endl;
    }
}

int main()
{
    int i = 0, j[2] = {0, 1};
    print1(&i);
    print1(j);
    print2(&i, 1);

    //璁＄畻寰楀埌鏁扮粍j鐨勫閲?
    print2(j, sizeof(j) / sizeof(*j));
    auto b = begin(j);
    auto e = end(j);
    print3(b, e);
    return 0;
}
#include <iostream>
#include <map>
#include <string>
#include <algorithm>
using namespace std;

void add_child(multimap<string, string> &families, const string &family, const string &child)
{
    families.insert({family, child});
}

int main(int argc, char *argv[])
{
    multimap<string, string> families;

    add_child(families, "张", "强");
    add_child(families, "张", "刚");
    add_child(families, "王", "五");

    for (auto f : families)
    {
        cout << f.first << "家的孩子：" << f.second << endl;
    }
    return 0;
}
#include <iostream>
#include <cstring>
using namespace std;

int main(int argc, char **argv)
{
	const char *c1 = "Hello ";
	const char *c2 = "World";

    // 字符串所需空间等于字符数+1
	char *r = new char[strlen(c1) + strlen(c2) + 1];
	strcpy(r, c1);    // 拷贝第一个字符串常量
	strcat(r, c2);    // 连接第二个字符串常量
	cout << r << endl;

    string s1 = "hello ";
    string s2 = "world";
    strcpy(r, (s1+s2).c_str()); // 拷贝连接结果
    cout << r << endl;

    // 释放动态数组
    delete [] r;
	return 0;
}
#include <iostream>
#include "Sales_item.h"

int main()
{
    Sales_item trans1, trans2;
    int num = 1;
    std::cout << "请输入若干销售记录：" << std::endl;
    if (std::cin >> trans1)
    {
        while (std::cin >> trans2)
        {
            if (compareIsbn(trans1, trans2)) // ISBN 相同
            {
                num++;
            }
            else // ISBN 不同
            {
                std::cout << trans1.isbn() << "共有" << num << "条销售记录" << std::endl;
                trans1 = trans2;
                num = 1;
            }
        }
        std::cout << trans1.isbn() << "共有" << num << "条销售记录" << std::endl;
    }
    else
    {
        std::cout << "没有数据" << std::endl;
        return -1;
    }
    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> iv;     // int的vector

    cout << iv.at(0) << endl;
    cout << iv[0] << endl;
    cout << iv.front() << endl;
    cout << *(iv.begin()) << endl;

    return 0;
}
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
#include <functional>
#include "make_plural.h"
using namespace std;
using namespace std::placeholders;

bool check_size(const string &s, string::size_type sz)
{
    return s.size() <= sz;
}

void biggies(vector<int> &vc, const string &s)
{
    // 查找第一个大于等于s长度的数值
    auto p = find_if(vc.begin(), vc.end(), bind(check_size, s, _1));
    // 打印结果
    cout << "第" << p-vc.begin() + 1 << "个数" << *p << "大于等于" << s << "的长度" << endl;
}

int main(int argc, char *argv[])
{
    vector<int> vc = { 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    biggies(vc, "Hello");
    biggies(vc, "everyone");
    biggies(vc, "!");
    return 0;
}
#include <iostream>
#include <cstring>
using namespace std;

int main(int argc, char **argv)
{
    char c;

    // 分配20个字符的动态数组
    // 因此最多存放19个字符
    char *r = new char[20];
    int l = 0;

    while (cin.get(c))
    {
        if (isspace(c)) // 空格、制表等空白符
        {
            break;
        }
        r[l++] = c;     // 存入动态数组
        if (l == 20)  // 已读入19个字符
        {
            cout << "达到数组容量上限" << endl;
            break;
        }
    }
    r[l] = 0;
    cout << r << endl;

    // 释放动态数组
    delete [] r;
    return 0;
}
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
	{
		cout << *p << endl;
	}

	cout << endl;
	Blob<string> b3(b1.begin(), b1.end());
	for(auto p = b3.begin(); p != b3.end(); ++p)
	{
		cout << *p << endl;
	}

	return 0;
}
锘?include <iostream>
#include <string>
#include <regex>
using namespace std;

int main()
{
	string phone = "(\\()?(\\d{3})(\\))?([-. ])?(\\d{3})([-. ])?(\\d{4})";
	regex r(phone); // 瀵绘壘妯″紡鎵€鐢ㄧ殑regex瀵硅薄
	smatch m;
	string s;
	string fmt = "$2.$5.$7"; // 灏嗗彿鐮佹牸寮忔敼涓篸dd.ddd.dddd
	// 浠庤緭鍏ユ枃浠朵腑璇诲彇姣忔潯璁板綍
	while (getline(cin, s))
    {
		cout << regex_replace(s, r, fmt) << endl;
    }
	return 0;
}
#include <iostream>
#include <stdexcept>
using namespace std;

int main()
{
    cout << "请依次输入被除数和除数：" << endl;
    int ival1, ival2;
    cin >> ival1 >> ival2;
    if (ival2 == 0)
    {
        throw runtime_error("除数不能为0");
    }
    cout << "两数相除的结果是：" << ival1 / ival2 << endl;
    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> vInt;
    int iVal;
    cout << "请输入一组数字：" << endl;
    while (cin >> iVal)
    {
        vInt.push_back(iVal);
    }
    if(vInt.cbegin() == vInt.cend())
    {
        cout << "没有任何元素" << endl;
        return -1;
    }

    cout << "相邻两项的和依次是：" << endl;
    //利用auto推断it的类型
    for (auto it = vInt.cbegin(); it != vInt.cend() - 1; it++)
    {
        //求相邻两项的和
        cout << (*it + *(++it)) << " ";
        //每行输出5个数字
        if ((it - vInt.cbegin() + 1) % 10 == 0)
        {
            cout << endl;
        }
    }
    //如果元素数是奇数，单独处理最后一个元素
    if (vInt.size() % 2 != 0)
    {
        cout << *(vInt.cend() - 1);
    }

    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> vInt;
    int iVal;
    cout << "请输入一组数字：" << endl;
    while (cin >> iVal)
    {
        vInt.push_back(iVal);
    }
    if (vInt.cbegin() == vInt.cend())
    {
        cout << "没有任何元素" << endl;
        return -1;
    }

    cout << "首尾两项的和依次是：" << endl;
    auto beg = vInt.begin();
    auto end = vInt.end();
    //利用auto推断it的类型
    for (auto it = beg; it != beg + (end - beg) / 2; it++)
    {
        //求首尾两项的和
        cout << (*it + *(beg + (end - it) - 1)) << " ";
        //每行输出5个数字
        if ((it - beg + 1) % 5 == 0)
        {
            cout << endl;
        }
    }
    //如果元素数是奇数，单独处理最后一个元素
    if (vInt.size() % 2 != 0)
    {
        cout << *(beg + (end - beg) / 2);
    }

    return 0;
}
#include <iostream>
#include <stdexcept>
using namespace std;

int main()
{
    cout << "请依次输入被除数和除数：" << endl;
    int ival1, ival2;
    while (cin >> ival1 >> ival2)
    {
        try
        {
            if (ival2 == 0)
            {
                throw runtime_error("除数不能为0");
            }
            cout << "两数相除的结果是：" << ival1 / ival2 << endl;
        }
        catch (runtime_error err)
        {
            cout << err.what() << endl;
            cout << "需要继续吗（y or n）？";
            char ch;
            cin >> ch;
            if(ch != 'y' && ch != 'Y')
            {
                break;
            }
        }
    }

    return 0;
}
#include <iostream>
using namespace std;

int main(int argc, char **argv)
{
    string str;
    for (int i = 0; i != argc; ++i)
    {
        str += argv[i];
    }
    cout << str << endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
#include <functional>
#include "make_plural.h"
using namespace std;
using namespace std::placeholders;

void elimDups(vector<string> &words)
{
    sort(words.begin(), words.end());
    auto end_unique = unique(words.begin(), words.end());
    words.erase(end_unique, words.end());
}

bool check_size(const string &s, string::size_type sz)
{
    return s.size() >= sz;
}

void biggies(vector<string> &words, vector<string>::size_type sz)
{
    elimDups(words); // 将words按字典序排序，删除重复单词
    for_each(words.begin(), words.end(),
         [](const string &s) {cout << s << " ";});
    cout << endl;
    // 获取一个迭代器，指向最后一个满足size()>= sz的元素之后位置
    auto wc = partition(words.begin(), words.end(), bind(check_size, _1, sz));
    // 计算满足size >= sz的元素的数目
    auto count = wc - words.begin();
    cout << count << " " << make_plural(count, "word", "s") << " of length " << sz << " or longer" << endl;
    // 打印长度大于等于给定值的单词，每个单词后面接一个空格
    for_each(words.begin(), wc,
         [](const string &s) {cout << s << " ";});
    cout << endl;
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<string> words;
    string word;
    while (in >> word)
    {
        words.push_back(word);
    }

    biggies(words, 6);
    return 0;
}
锘?include <iostream>
using std::cin; using std::cout; using std::cerr;
using std::istream; using std::ostream; using std::endl;

#include <sstream>
using std::ostringstream; using std::istringstream;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <regex>
using std::regex; using std::smatch; using std::regex_match;
using std::sregex_iterator;

// members are public by default
struct PersonInfo
{
	string name;
	vector<string> phones;
};

// we'll see how to reformat phone numbers in chapter 17
// for now just return the string we're given
string format(const string &s) { return s; }

bool valid(const smatch& m)
{
	if(m[1].matched)
	{
		// the area code must be followed by a close parenthesis
		// and followed immediately by the rest of the number or a space
	    return m[3].matched && (m[4].matched == 0 || m[4].str() == " ");
	}
	else
	{
		// then there can't be a close after the area code
		// the delimiters between the other two components must match
		return !m[3].matched && m[4].str() == m[6].str();
	}
}

vector<PersonInfo>
getData(istream &is)
{
	string phone = "(\\()?(\\d{3})(\\))?([-. ])?(\\d{3})([-. ]?)(\\d{4})";
	regex r(phone);  // a regex to find our pattern
	smatch m;        // a match object to hold the results

	// will hold a line and word from input, respectively
	string line, word;

	// will hold all the records from the input
	vector<PersonInfo> people;

	// read the input a line at a time until end-of-file (or other error)
	while (getline(is, line))
	{
		PersonInfo info;            // object to hold this record's data
	  	istringstream record(line); // bind record to the line we just read
		record >> info.name;        // read the name
		getline(record, line);
		sregex_iterator it(line.begin(), line.end(), r), end_it;
		if (it != end_it && valid(*it))	// match the phone numbers and check and store them
		{
				info.phones.push_back("V" + it->str());
		}
		else
		{
			info.phones.push_back("I" + it->str());
		}

		people.push_back(info); // append this record to people
	}

	return people;
}

ostream& process(ostream &os, vector<PersonInfo> people)
{
	for (const auto &entry : people)    // for each entry in people
	{
		ostringstream formatted, badNums; // objects created on each loop
		for (const auto &nums : entry.phones)  // for each number
		{
			if (nums[0] == 'I')
			{
				badNums << " " << nums.substr(1) << endl;  // string in badNums
			}
			else
			{
				// ``writes'' to formatted's string
				formatted << " " << format(nums.substr(1)) << endl;
			}
		}
		if (badNums.str().empty())      // there were no bad numbers
		{
			os << entry.name << endl     // print the name
			   << formatted.str() << endl; // and reformatted numbers
		}
		else                   // otherwise, print the name and bad numbers
		{
			cerr << "input error: " << entry.name
			     << " invalid number(s) " << badNums.str() << endl;
		}
	}

	return os;
}

int main()
{
	process(cout, getData(cin));
	return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    //该vector对象记录各分数段的人数，初始值均为0
    vector<unsigned> vUS(11);
    auto it = vUS.begin();
    int iVal, iCount = 0;
    cout << "请输入一组成绩（0~100）：" << endl;
    while (cin >> iVal)
    {
        if (iVal < 101)  //成绩应在合理范围之内
        {
            ++*(it + iVal / 10);    //利用迭代器定位到对应的元素，加1
            ++iCount;
        }
    }
    cout << "您总计输入了 " << iCount << " 个成绩" << endl;
    cout << "各分数段的人数分布是（成绩从低到高）：" << endl;
    //利用迭代器遍历vUS的元素并逐个输出
    for (it = vUS.begin(); it != vUS.end(); it++)
    {
        cout << *it << " ";
    }
    cout << endl;

    return 0;
}
#include <iostream>
#include <vector>
#include <list>
using namespace std;

int main()
{
    int ia[] = {0, 1, 1, 2, 3, 5, 8, 13, 21, 55, 89};
    vector<int> iv;
    list<int> il;

    iv.assign(ia, ia + 11);   // 将数据拷贝到vector
    il.assign(ia, ia + 11);   // 将数据拷贝到list

    vector<int>::iterator iiv = iv.begin();
    while (iiv != iv.end())
    {
        if (!(*iiv & 1))        // 偶数
        {
            iiv = iv.erase(iiv);  // 删除偶数，返回下一位置迭代器
        }
        else
        {
            iiv++;             // 推进到下一位置
        }
    }

    list<int>::iterator iil = il.begin();
    while (iil != il.end())
    {
        if (*iil & 1)           // 奇数
        {
            iil = il.erase(iil);  // 删除奇数，返回下一位置迭代器
        }
        else
        {
            iil++;             // 推进到下一位置
        }
    }

    for (iiv = iv.begin(); iiv != iv.end(); iiv++)
    {
        cout << *iiv << " ";
    }
    cout << endl;

    for (iil = il.begin(); iil != il.end(); iil++)
    {
        cout << *iil << " ";
    }
    cout << endl;

    return 0;
}
#include <iostream>
#include <string>
#include <memory>
using namespace std;

int main(int argc, char **argv)
{
    allocator<string> alloc;
    // 分配100个未初始化的string
    auto const p = alloc.allocate(100);
    string s;
    string *q = p; 					// q指向第一个string
    while (cin >> s && q != p + 100)
    {
        alloc.construct(q++, s); 		// 用s初始化*q
    }
    const size_t size = q - p; 		// 记住读取了多少个string

    // 使用数组
    for (size_t i = 0; i < size; i++)
    {
        cout << p[i] << " " << endl;
    }

    while (q != p)        // 使用完毕后释放已构造的string
    {
        alloc.destroy(--q);
    }
    alloc.deallocate(p, 100); // 释放内存
    return 0;
}
#include <iostream>
#include "my_StrBlob.h"
using namespace std;

int main(int argc, char **argv)
{
	StrBlob b1;
	{
	    StrBlob b2 = { "a", "an", "the" };
	    b1 = b2;
	    b2.push_back("about");
      	cout << "b2大小为" << b2.size() << endl;
      	cout << "b2首尾元素为" << b2.front() << " " << b2.back() << endl;
	}
	cout << "b1大小为" << b1.size() << endl;
	cout << "b1首尾元素为" << b1.front() << " " << b1.back() << endl;

	StrBlob b3 = b1;
	b3.push_back("next");
	cout << "b3大小为" << b3.size() << endl;
	cout << "b3首尾元素为" << b3.front() << " " << b3.back() << endl;

	cout << "b1全部元素：" << endl;
	for (auto it = b1.begin(); neq(it, b1.end()); it.incr())
	{
		cout << it.deref() << endl;
	}

	return 0;
}
#include <iostream>
#include <string>
#include "Bulk_quote.h"
using namespace std;

int main(int argc, const char *argv[])
{
    Quote base("C++ Primer", 128.0);
    Bulk_quote bulk("Core Python Programming", 89, 5, 0.19);
    cout << base << endl;
    cout << bulk << endl;
    return 0;
}
锘?include <iostream>
using std::cin; using std::cout; using std::cerr;
using std::istream; using std::ostream; using std::endl;

#include <sstream>
using std::ostringstream; using std::istringstream;

#include <vector>
using std::vector;

#include <string>
using std::string;

#include <regex>
using std::regex; using std::smatch; using std::regex_match;
using std::sregex_iterator;

// members are public by default
struct PersonInfo
{
	string name;
	vector<string> phones;
};

// we'll see how to reformat phone numbers in chapter 17
// for now just return the string we're given
string format(const string &s) { return s; }

bool valid(const smatch& m)
{
	if(m[1].matched)
	{
		// the area code must be followed by a close parenthesis
		// and followed immediately by the rest of the number or a space
	    return m[3].matched && (m[4].matched == 0 || m[4].str() == " ");
	}
	else
	{
		// then there can't be a close after the area code
		// the delimiters between the other two components must match
		return !m[3].matched && m[4].str() == m[6].str();
	}
}

vector<PersonInfo>
getData(istream &is)
{
	string phone = "(\\()?(\\d{3})(\\))?([-. ])?(\\d{3})([-. ]?)(\\d{4})";
	regex r(phone);  // a regex to find our pattern
	smatch m;        // a match object to hold the results

	// will hold a line and word from input, respectively
	string line, word;

	// will hold all the records from the input
	vector<PersonInfo> people;

	// read the input a line at a time until end-of-file (or other error)
	while (getline(is, line))
	{
		PersonInfo info;            // object to hold this record's data
		istringstream record(line); // bind record to the line we just read
		record >> info.name;        // read the name
		getline(record, line);
		sregex_iterator it(line.begin(), line.end(), r), end_it;
		for (it++; it != end_it; it++)	// match the phone numbers and check and store them
		{
			if (valid(*it))
			{
				info.phones.push_back("V" + it->str());
			}
			else
			{
				info.phones.push_back("I" + it->str());
			}
		}

		people.push_back(info); // append this record to people
	}

	return people;
}

ostream& process(ostream &os, vector<PersonInfo> people)
{
	for (const auto &entry : people)    // for each entry in people
	{
		ostringstream formatted, badNums; // objects created on each loop
		for (const auto &nums : entry.phones)  // for each number
		{
			if (nums[0] == 'I')
			{
				badNums << " " << nums.substr(1) << endl;  // string in badNums
			}
			else
			{
				// ``writes'' to formatted's string
				formatted << " " << format(nums.substr(1)) << endl;
			}
		}
		if (badNums.str().empty())      // there were no bad numbers
		{
			os << entry.name << endl     // print the name
			   << formatted.str() << endl; // and reformatted numbers
		}
		else                   // otherwise, print the name and bad numbers
		{
			cerr << "input error: " << entry.name
			     << " invalid number(s) " << badNums.str() << endl;
		}
	}

	return os;
}

int main()
{
	process(cout, getData(cin));
	return 0;
}
#include <iostream>
using namespace std;

int main(int argc, char **argv)
{
    for (int i = 0; i != argc; ++i)
    {
        cout << "argc[" << i << "]: " << argv[i] << endl;
    }
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

class Screen
{
private:
	unsigned height = 0, width = 0;
	unsigned cursor = 0;
	string contents;
public:
	Screen() = default;	//榛樿鏋勯€犲嚱鏁?
	Screen(unsigned ht, unsigned wd) : height(ht), width(wd), contents(ht * wd, ' ') { }
	Screen(unsigned ht, unsigned wd, char c) : height(ht), width(wd), contents(ht * wd, c) { }
public:
    Screen& move(unsigned r, unsigned c)
    {
        cursor = r * width + c;
        return *this;
    }
    Screen& set(char ch)
    {
        contents[ cursor ] = ch;
        return *this;
    }
    Screen& set(unsigned r, unsigned c, char ch)
    {
        contents[ r * width + c ] = ch;
        return *this;
    }
    Screen& display()
    {
        cout << contents;
        return *this;
    }
};


int main()
{
    Screen myScreen(5, 5, 'X');
    myScreen.move(4,0).set('#').display();
    cout << "\n";
    myScreen.display();
    cout << "\n";

    return 0;
}
#include <iostream>
#include <forward_list>
using namespace std;

int main()
{
    forward_list<int> iflst = {1, 2, 3, 4, 5, 6, 7, 8};
    auto prev = iflst.before_begin();     // 前驱元素
    auto curr = iflst.begin();            // 当前元素
    while (curr != iflst.end())
    {
        if (*curr & 1)                      // 奇数
        {
            curr = iflst.erase_after(prev);   // 删除，移动到下一元素
        }
        else
        {
            prev = curr;                // 前驱和当前迭代器都向前推进
            curr++;
        }
    }

    for (curr = iflst.begin(); curr != iflst.end(); curr++)
    {
        cout << *curr << " ";
    }
    cout << endl;

    return 0;
}
#include <iostream>
#include <vector>
#include <list>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    vector<int> vi = { 1, 2, 2, 3, 4, 5, 5, 6};
    list<int> li;

    unique_copy(vi.begin(), vi.end(), back_inserter(li));

    for (auto v : li)
    {
        cout << v << " ";
    }
    cout << endl;
    return 0;
}
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
    while (true)
    {
        cout << "enter word to look for, or q to quit: ";
        string s;
        // stop if we hit end-of-file on the input or if a 'q' is entered
        if (!(cin >> s) || s == "q")
        {
            break;
        }
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
    if (argc < 2 || !(infile.open(argv[1]), infile))
    {
        cerr << "No input file!" << endl;
        return EXIT_FAILURE;
    }
	runQueries(infile);
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

class HasPtr
{
public:
    // 构造函数分配新的string和新的计数器，将计数器置为1
    HasPtr(const string &s = string()) : ps(new string(s)), i(0), use(new size_t(1)) {}
    // 拷贝构造函数拷贝所有三个数据成员，并递增计数器
    HasPtr(const HasPtr &p) : ps(p.ps), i(p.i), use(p.use) { ++*use; }  // 拷贝构造函数
    HasPtr& operator=(const HasPtr&);  // 拷贝赋值运算符
    HasPtr& operator=(const string&);  // 赋予新string
    string& operator*();       // 解引用
    ~HasPtr();
private:
    string *ps;
    int i;
    size_t *use; // 用来记录有多少个对象共享*ps的成员
};

HasPtr::~HasPtr()
{
    if (--*use == 0) 	// 如果引用计数变为0
    {
        delete ps; 		// 释放string内存
        delete use; 		// 释放计数器内存
    }
}

HasPtr& HasPtr::operator=(const HasPtr &rhs)
{
    ++*rhs.use; // 递增右侧运算对象的引用计数
    if (--*use == 0) 	// 然后递减本对象的引用计数
    {
        delete ps; 		// 如果没有其他用户
        delete use; 		// 释放本对象分配的成员
    }
    ps = rhs.ps; 		// 将数据从rhs拷贝到本对象
    i = rhs.i;
    use = rhs.use;
    return *this; 		// 返回本对象
}

HasPtr& HasPtr::operator=(const string &rhs)
{
    *ps = rhs;
    return *this;
}

string& HasPtr::operator*()
{
    return *ps;
}

int main(int argc, char **argv)
{
    HasPtr h("hi mom!");
    HasPtr h2 = h;  // 未分配新string，h2和h指向相同的string
    h = "hi dad!";
    cout << "h: " << *h << endl;
    cout << "h2: " << *h2 << endl;
    return 0;
}
锘?include <iostream>
#include <string>
#include <regex>

using namespace std;

int main()
{
	string zip = "(\\d{5})((-?)(\\d{4}))?";
	regex r(zip); // 瀵绘壘妯″紡鎵€鐢ㄧ殑regex瀵硅薄
	string s;
	string fmt = "$1-$2"; // 灏嗛偖鏀跨紪鐮佹牸寮忔敼涓篸dddd-dddd
	// 浠庤緭鍏ユ枃浠朵腑璇诲彇姣忔潯璁板綍
	while (getline(cin, s))
	{
		for (sregex_iterator it(s.begin(), s.end(), r), end_it; it != end_it; it++)
		{
			if ((*it)[2].matched && (*it)[2].str()[0] != '-')
			{
				cout << (*it).format(fmt) << endl;
			}
			else
			{
				cout << (*it).str() << endl;
			}
		}
	}

	return 0;
}
#include <iostream>
using namespace std;

int iCount(initializer_list<int> il)
{
    int count = 0;
    //遍历il的每一个元素
    for (auto val : il)
    {
        count += val;
    }
    return count;
}

int main()
{
    //使用列表初始化的方式构建initializer_list<int>对象
    //然后把它作为实参传递给函数iCount
    cout << "1,6,9的和是：" << iCount({1, 6, 9}) << endl;
    cout << "4,5,9,18的和是：" << iCount({4, 5, 9, 18}) << endl;
    cout << "10,10,10,10,10,10,10,10,10的和是：" << iCount({10, 10, 10, 10, 10, 10, 10, 10, 10}) << endl;
    return 0;
}
#include <iostream>
using namespace std;

int main()
{
    cout << "类型名称\t" << "所占空间" << endl;
    cout << "bool\t\t" << sizeof(bool) << endl;
    cout << "char\t\t" << sizeof(char) << endl;
    cout << "wchar_t\t\t" << sizeof(wchar_t) << endl;
    cout << "char16_t\t" << sizeof(char16_t) << endl;
    cout << "char32_t\t" << sizeof(char32_t) << endl;
    cout << "short\t\t" << sizeof(short) << endl;
    cout << "int\t\t" << sizeof(int) << endl;
    cout << "long\t\t" << sizeof(long) << endl;
    cout << "long long\t" << sizeof(long long) << endl;
    cout << "float\t\t" << sizeof(float) << endl;
    cout << "double\t\t" << sizeof(double) << endl;
    cout << "long double\t" << sizeof(long double) << endl;
    return 0;
}
#include <iostream>
#include <forward_list>
using namespace std;

void test_and_insert(forward_list<string> &sflst, const string &s1, const string &s2)
{
    auto prev = sflst.before_begin();     // 前驱元素
    auto curr = sflst.begin();            // 当前元素
    bool inserted = false;

    while (curr != sflst.end())
    {
        if (*curr == s1)  // 找到给定字符串
        {
            curr = sflst.insert_after(curr, s2);  // 插入新字符串，curr指向它
            inserted = true;
        }
        prev = curr;                        // 前驱迭代器向前推进
        curr++;                             // 当前迭代器向前推进
    }

    if (!inserted)
    {
        sflst.insert_after(prev, s2);        // 未找到给定字符串，插入尾后
    }
}

int main()
{
    forward_list<string> sflst = {"Hello", "!", "world", "!"};

    test_and_insert(sflst, "Hello", "你好");
    for (auto curr = sflst.cbegin(); curr != sflst.cend(); curr++)
    {
      cout << *curr << " ";
    }
    cout << endl;

    test_and_insert(sflst, "!", "?");
    for (auto curr = sflst.cbegin(); curr != sflst.cend(); curr++)
    {
      cout << *curr << " ";
    }
    cout << endl;

    test_and_insert(sflst, "Bye", "再见");
    for (auto curr = sflst.cbegin(); curr != sflst.cend(); curr++)
    {
      cout << *curr << " ";
    }
    cout << endl;

    return 0;
}
#include <iostream>
#include <vector>
#include <list>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    vector<int> vi = { 1, 2, 3, 4, 5, 6, 7, 8, 9};
    list<int> li1, li2, li3;

    unique_copy(vi.begin(), vi.end(), inserter(li1, li1.begin()));
    for (auto v : li1)
    {
        cout << v << " ";
    }
    cout << endl;

    unique_copy(vi.begin(), vi.end(), back_inserter(li2));
    for (auto v : li2)
    {
        cout << v << " ";
    }
    cout << endl;

    unique_copy(vi.begin(), vi.end(), front_inserter(li3));
    for (auto v : li3)
    {
        cout << v << " ";
    }
    cout << endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <cstdlib>  // 要使用EXIT_FAILURE
#include "make_plural.h"
using namespace std;
using line_no = vector<string>::size_type;

vector<string> file;      // 文件每行内容
map<string, set<line_no>> wm; // 单词到行号set的映射

string cleanup_str(const string &word)
{
    string ret;
    for (auto it = word.begin(); it != word.end(); ++it)
    {
        if (!ispunct(*it))
        {
            ret += tolower(*it);
        }
    }
    return ret;
}

void input_text(ifstream &is)
{
    string text;
    while (getline(is, text)) 		// 对文件中每一行
    {
        file.push_back(text); 		// 保存此行文本
        int n = file.size() - 1; 	// 当前行号
        istringstream line(text); 	// 将行文本分解为单词
        string word;
        while (line >> word) 		// 对行中每个单词
        {
            // 将当前行号插入到其行号set中
            // 如果单词不在wm中，以之为下标在wm中添加一项
            wm[cleanup_str(word)].insert(n);
        }
    }
}

ostream &query_and_print(const string &sought, ostream & os)
{
    // 使用find而不是下标运算符来查找单词，避免将单词添加到wm中！
    auto loc = wm.find(sought);
    if (loc == wm.end())  // 未找到
    {
        os << sought << "出现了0次" << endl;
    }
    else
    {
        auto lines = loc->second;   // 行号set
        os << sought << "出现了" << lines.size() << "次" << endl;
        for (auto num : lines)    // 打印单词出现的每一行
        {
            os << "\t(第" << num + 1 << "行) " << *(file.begin() + num) << endl;
        }
    }
    return os;
}

void runQueries(ifstream &infile)
{
    // infile是一个ifstream，指向我们要查询的文件
    input_text(infile); // 读入文本并建立查询map
    // 与用户交互：提示用户输入要查询的单词，完成查询并打印结果
    while (true)
    {
        cout << "enter word to look for, or q to quit: ";
        string s;
        // 若遇到文件尾或用户输入了’q’时循环终止
        if (!(cin >> s) || s == "q")
        {
            break;
        }
        // 指向查询并打印结果
        query_and_print(s, cout) << endl;
    }
}

// 程序接受唯一的命令行参数，表示文本文件名
int main(int argc, char **argv)
{
    // 打开要查询的文件
    ifstream infile;
  	// 打开文件失败，程序异常退出
    if (argc < 2 || !(infile.open(argv[1]), infile))
    {
        cerr << "No input file!" << endl;
        return EXIT_FAILURE;
    }
  	runQueries(infile);
    return 0;
}
#include <iostream>
#include <string>
#include <vector>
#include "Bulk_quote.h"
using namespace std;

int main()
{
    vector<Quote> itemVec;
    for (size_t i = 0; i != 10; ++i)
    {
        Bulk_quote item("C++ Primer", 6, 5, 0.5);
        itemVec.push_back(item);
    }

    double sum = 0;
    for (vector<Quote>::iterator iter = itemVec.begin(); iter != itemVec.end(); ++iter)
    {
        sum += iter->net_price(10);   //璋冪敤Quote:: net_price
    }

    cout << sum << endl;    //output 600
}
#include <iostream>
#include <random>
using namespace std;

unsigned int rand_int()
{
    // 生成0到9999之间（包含）均匀分布的随机数
    static uniform_int_distribution<unsigned> u(0,9999);
    static default_random_engine e; // 生成无符号随机整数

    return u(e);
}

int main()
{
    for (int i = 0; i < 10; i++)
    {
        cout << rand_int() << " ";
    }
    cout << endl;
	return 0;
}
#include <string>
using std::string;

#include <iostream>
using std::cout; using std::endl;

#include <vector>
using std::vector;

#include "sp_Blob.h"

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
	for(size_t i = 0; i < b1.size(); ++i)
    {
		cout << b1.at(i) << " ";
    }
    cout << endl << endl;

    // test make_SP
    vector<string> vs = {"Hello", "World", "!"};
    Blob<string> b3(vs.begin(), vs.end());
    cout << b3.size() << endl;
    for(size_t i = 0; i < b3.size(); ++i)
    {
    	cout << b3.at(i) << " ";
    }
    cout << endl << endl;

    string as[3] = {"This", "is", "end"};
    Blob<string> b4(as, as + 3);
    cout << b4.size() << endl;
    for(size_t i = 0; i < b4.size(); ++i)
    {
    	cout << b4.at(i) << " ";
    }
    cout << endl << endl;

    UP<int> u1(new int(42));
    cout << *u1 << endl;
    UP<int> u2(u1.release());
    cout << *u2 << endl;

	return 0;
}
#include <iostream>
using namespace std;
//定义在全局作用域中的数组
string sa[10];
int ia[10];

int main()
{
    //定义在局部作用域中的数组
    string sa2[10];
    int ia2[10];
    for (auto c : sa)
    {
        cout << c << " ";
    }
    cout << endl;

    for (auto c : ia)
    {
        cout << c << " ";
    }
    cout << endl;

    for (auto c : sa2)
    {
        cout << c << " ";
    }
    cout << endl;

    for (auto c : ia2)
    {
        cout << c << " ";
    }
    return 0;
}
#include <iostream>
#include <random>
using namespace std;

unsigned int rand_int(long seed = -1)
{
    // 生成0到9999之间（包含）均匀分布的随机数
    static uniform_int_distribution<unsigned> u(0,9999);
    static default_random_engine e; // 生成无符号随机整数

    if (seed >= 0)
    {
        e.seed(seed);
    }
    return u(e);
}

int main()
{
    for (int i = 0; i < 10; i++)
    {
        cout << rand_int() << " ";
    }
    cout << endl;

    cout << rand_int(0) << " ";
    for (int i = 0; i < 9; i++)
    {
        cout << rand_int() << " ";
    }
    cout << endl;

    cout << rand_int(19743) << " ";
    for (int i = 0; i < 9; i++)
    {
        cout << rand_int() << " ";
    }
    cout << endl;

  	return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <iterator>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    // 创建流迭代器从文件读入字符串
    istream_iterator<string> in_iter(in);
    // 尾后迭代器
    istream_iterator<string> eof;
    vector<string> words;
    while (in_iter != eof)
    {
        words.push_back(*in_iter++);  // 存入vector并递增迭代器
    }

    for (auto word : words)
    {
        cout << word << " ";
    }
    cout << endl;
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()  //使用getline一次读入一整行，遇回车结束
{
    string line;
    // 循环读取，每次读入一整行，直至文件结束或遇到异常输入
    cout << "请输入您的字符串，可以包含空格：" << endl;
    while (getline(cin, line))
    {
        cout << line << endl;
    }

    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()      //使用cin一次读入一个词，遇空白结束
{
    string word;
    // 循环读取，每次读入一个词，直至文件结束或遇到异常输入
    cout << "请输入您的单词，不可以包含空格：" << endl;
    while (cin >> word)
    {
        cout << word << endl; 	//为了便于观察，输出每个单词后换行
    }

    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    string word, line;
    cout << "请选择读取字符串的方式：1表示逐词读取，2表示整行读取" << endl;
    char ch;
    cin >> ch;
    if (ch == '1')
    {
        cout << "请输入字符串：   Welcome to C++ family!   " << endl;
        cin >> word;
        cout << "系统读取的有效字符串是：" << endl;
        cout << word << endl;
        return 0;
    }
	//清空输入缓冲区
    cin.clear();
    cin.sync();
    if (ch == '2')
    {
        cout << "请输入字符串：   Welcome to C++ family!   " << endl;
        getline(cin, line);
        cout << "系统读取的有效字符串是：" << endl;
        cout << line << endl;
        return 0;
    }
    cout << "您的输入有误！";
    return -1;
}
#include <iostream>
#include "Sales_data.h"
using namespace std;

int main()
{
    cout << "璇疯緭鍏ヤ氦鏄撹褰曪紙ISBN銆侀攢鍞噺銆佸師浠枫€佸疄闄呭敭浠凤級锛? << endl;
    Sales_data total; //淇濆瓨涓嬩竴鏉′氦鏄撹褰曠殑鍙橀噺
    // 璇诲叆绗竴鏉′氦鏄撹褰曪紝骞剁‘淇濇湁鏁版嵁鍙互澶勭悊
    if (cin >> total)
    {
        Sales_data trans; //淇濆瓨鍜岀殑鍙橀噺
        //璇诲叆骞跺鐞嗗墿浣欎氦鏄撹褰?
        while (cin >> trans)
        {
            //濡傛灉鎴戜滑浠嶅湪澶勭悊鐩稿悓鐨勪功
            if (total.isbn() == trans.isbn())
            {
                total.combine(trans); //鏇存柊鎬婚攢鍞
            }
            else
            {
                //鎵撳嵃鍓嶄竴鏈功鐨勭粨鏋?
                cout << total << endl;
                total = trans; //total鐜板湪琛ㄧず涓嬩竴鏈功鐨勯攢鍞
            }
        }
        cout << total << endl; //鎵撳嵃鏈€鍚庝竴鏈功鐨勭粨鏋?
    }
    else
    {
        //娌℃湁杈撳叆锛佽鍛婅鑰?
        cerr << "No data?!" << endl;
        return -1; //琛ㄧず澶辫触
    }
    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<int> vi;
    int val;
    while (in >> val)
    {
        vi.push_back(val);
    }
    cout << "序列中整数之和为" << accumulate(vi.begin(), vi.end(), 0) << endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <map>
#include <string>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    map<string, size_t> word_count;
    string word;
    while (in >> word)
    {
        ++word_count[word];
    }

  	for (const auto &w : word_count)
    {
  	   	cout << w.first << "出现了" << w.second << "次" << endl;
    }
    return 0;
}
#include <string>
using std::string;

#include <fstream>
using std::ifstream;

#include <iostream>
using std::cin; using std::cout; using std::cerr;
using std::endl;

#include <cstdlib>  // for EXIT_FAILURE

#include "t_TextQuery.h"
#include "make_plural.h"

void runQueries(ifstream &infile)
{
	// infile is an ifstream that is the file we want to query
    TextQuery tq(infile);  // store the file and build the query map
    // iterate with the user: prompt for a word to find and print results
    while (true)
    {
        cout << "enter word to look for, or q to quit: ";
        string s;
        // stop if we hit end-of-file on the input or if a 'q' is entered
        if (!(cin >> s) || s == "q")
        {
            break;
        }
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
    if (argc < 2 || !(infile.open(argv[1]), infile))
    {
        cerr << "No input file!" << endl;
        return EXIT_FAILURE;
    }
	runQueries(infile);
    return 0;
}
#include <iostream>

int main()
{
    std::cout << "Hello, World" << std::endl;
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

class HasPtr
{
    friend void swap(HasPtr&, HasPtr&);
public:
    HasPtr(const string &s = string()) : ps(new string(s)), i(0) {}
    HasPtr(const HasPtr &p) : ps(new string(*p.ps)), i(p.i) { }  // 拷贝构造函数
    HasPtr& operator=(const HasPtr&);  // 拷贝赋值运算符
    HasPtr& operator=(const string&);  // 赋予新string
    string& operator*();       // 解引用
    ~HasPtr();
private:
    string *ps;
    int i;
};

HasPtr::~HasPtr()
{
    delete ps; 		// 释放string内存
}

inline HasPtr& HasPtr::operator=(const HasPtr &rhs)
{
    auto newps = new string(*rhs.ps); // 拷贝指针指向的对象
    delete ps;					// 销毁原string
    ps = newps;					// 指向新string
    i = rhs.i; 					// 使用内置的int赋值
    return *this; 				// 返回一个此对象的引用
}

HasPtr& HasPtr::operator=(const string &rhs)
{
    *ps = rhs;
    return *this;
}

string& HasPtr::operator*()
{
    return *ps;
}

inline void swap(HasPtr &lhs, HasPtr &rhs)
{
    cout << "交换 " << *lhs.ps << "和" << *rhs.ps << endl;
    swap(lhs.ps, rhs.ps);	// 交换指针，而不是string数据
    swap(lhs.i, rhs.i);    	// 交换int成员
}

int main(int argc, char **argv)
{
    HasPtr h("hi mom!");
    HasPtr h2(h);  // 行为类值，h2、h3和h指向不同string
    HasPtr h3 = h;
    h2 = "hi dad!";
    h3 = "hi son!";
    swap(h2, h3);
    cout << "h: " << *h << endl;
    cout << "h2: " << *h2 << endl;
    cout << "h3: " << *h3 << endl;
    return 0;
}
#include <iostream>
#include <random>
using namespace std;

unsigned int rand_int(long seed = -1, long min = 1, long max = 0)
{
    // 生成0到9999之间（包含）均匀分布的随机数
    static uniform_int_distribution<unsigned> u(0,9999);
    static default_random_engine e; // 生成无符号随机整数

    if (seed >= 0)
    {
        e.seed(seed);
    }

    if (min <= max)
    {
        u = uniform_int_distribution<unsigned>(min, max);
    }
    return u(e);
}

int main()
{
    for (int i = 0; i < 10; i++)
    {
        cout << rand_int() << " ";
    }
    cout << endl;

    cout << rand_int(0) << " ";
    for (int i = 0; i < 9; i++)
    {
        cout << rand_int() << " ";
    }
    cout << endl;

    cout << rand_int(19743) << " ";
    for (int i = 0; i < 9; i++)
    {
        cout << rand_int() << " ";
    }
    cout << endl;

    cout << rand_int(19743, 0, 9) << " ";
    for (int i = 0; i < 9; i++)
    {
        cout << rand_int() << " ";
    }
    cout << endl;

  	return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <iterator>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    // 创建流迭代器从标准输入读入整数
    istream_iterator<int> in_iter(cin);
    // 尾后迭代器
    istream_iterator<int> eof;
    vector<int> vi;
    while (in_iter != eof)
    {
        vi.push_back(*in_iter++);  // 存入vector并递增迭代器
    }

    sort(vi.begin(), vi.end());

    ostream_iterator<int> out_iter(cout, " ");
    copy(vi.begin(), vi.end(), out_iter);
    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <iterator>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    // 创建流迭代器从标准输入读入整数
    istream_iterator<int> in_iter(cin);
    // 尾后迭代器
    istream_iterator<int> eof;
    vector<int> vi;
    while (in_iter != eof)
    {
        vi.push_back(*in_iter++);  // 存入vector并递增迭代器
    }

    sort(vi.begin(), vi.end());

    ostream_iterator<int> out_iter(cout, " ");
    unique_copy(vi.begin(), vi.end(), out_iter);
    return 0;
}
#include <iostream>
#include <string>
#include <map>
#include <algorithm>
using namespace std;

void remove_author(multimap<string, string> &books, const string &author)
{
    auto pos = books.equal_range(author); // 查找给定作者范围
    if (pos.first == pos.second)  // 空范围，没有该作者
    {
        cout << "没有" << author << "这个作者" << endl << endl;
    }
    else
    {
        books.erase(pos.first, pos.second); // 删除该作者所有著作
    }
}

void print_books(multimap<string, string> &books)
{
    cout << "当前书目包括：" << endl;
    for (auto &book : books)  // 遍历所有书籍，打印之
    {
        cout << book.first << ", 《" << book.second << "》" << endl;
    }
    cout << endl;
}

int main(int argc, char *argv[])
{
  	multimap<string, string> books;
  	books.insert({"Barth, John", "Sot-Weed Factor"});
  	books.insert({"Barth, John", "Lost in the Funhouse"});
  	books.insert({"金庸", "射雕英雄传"});
  	books.insert({"金庸", "天龙八部"});

  	print_books(books);
  	remove_author(books, "张三");
    remove_author(books, "Barth, John");
    print_books(books);
    return 0;
}
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
using std::string;
using std::cout;
using std::endl;
using std::vector;
using std::to_string;

class HasPtr
{
    friend void swap(HasPtr&, HasPtr&);
public:
    HasPtr(const string &s = string()) : ps(new string(s)), i(0) {}
    HasPtr(const HasPtr &p) : ps(new string(*p.ps)), i(p.i) { }  // 拷贝构造函数
    HasPtr& operator=(const HasPtr&);  // 拷贝赋值运算符
    HasPtr& operator=(const string&);  // 赋予新string
    string& operator*();       // 解引用
    bool operator<(const HasPtr&) const; // 比较运算
    ~HasPtr();
private:
    string *ps;
    int i;
};

HasPtr::~HasPtr()
{
    delete ps; 		// 释放string内存
}

inline HasPtr& HasPtr::operator=(const HasPtr &rhs)
{
    auto newps = new string(*rhs.ps); // 拷贝指针指向的对象
    delete ps;					// 销毁原string
    ps = newps;					// 指向新string
    i = rhs.i; 					// 使用内置的int赋值
    return *this; 				// 返回此对象的引用
}

HasPtr& HasPtr::operator=(const string &rhs)
{
    *ps = rhs;
    return *this;
}

string& HasPtr::operator*()
{
    return *ps;
}

inline void swap(HasPtr &lhs, HasPtr &rhs)
{
    using std::swap;
    cout << "交换 " << *lhs.ps << "和" << *rhs.ps << endl;
    swap(lhs.ps, rhs.ps);	// 交换指针，而不是string数据
    swap(lhs.i, rhs.i);    	// 交换int成员
}

bool HasPtr::operator<(const HasPtr &rhs) const
{
    return *ps < *rhs.ps;
}

int main(int argc, char **argv)
{
    vector<HasPtr> vh;
    int n = atoi(argv[1]);
    for (int i = 0; i < n; i++)
    {
        vh.push_back(to_string(n-i));
    }

    for (auto p : vh)
    {
        cout << *p << " ";
    }
    cout << endl;

    sort(vh.begin(), vh.end());
    for (auto p : vh)
    {
        cout << *p << " ";
    }
    cout << endl;

  	return 0;
}
#include <iostream>
using namespace std;

int main()
{
    const int sz = 10;  //常量sz作为数组的维度
    int a[sz];
    //通过for循环为数组元素赋值
    for (int i = 0; i < sz; i++)
    {
        a[i] = i;
    }
    //通过范围for循环输出数组的全部元素
    for (auto val : a)
    {
        cout << val << " ";
    }
    cout << endl;

    return 0;
}
#include <iostream>
#include <forward_list>
using namespace std;

int main()
{
    forward_list<int> iflst = {0,1,2,3,4,5,6,7,8,9};
    auto prev = iflst.before_begin(); // 前驱结点
    auto curr = iflst.begin();        // 首结点

    while (curr != iflst.end())
    {
        if (*curr & 1)  // 奇数
        {
            curr = iflst.insert_after(curr, *curr); // 插入到当前元素之后
            prev = curr;    // prev移动到新插入元素
            curr++;         // curr移动到下一元素
        }
        else            // 偶数
        {
            curr = iflst.erase_after(prev);   // 删除，curr指向下一元素
        }
    }

    for (curr = iflst.begin(); curr != iflst.end(); curr++)
    {
        cout << *curr << " ";
    }
    cout << endl;

    return 0;
}
#include <iostream>
#include <list>
using namespace std;

int main()
{
    list<int> ilst = {0,1,2,3,4,5,6,7,8,9};
    auto curr = ilst.begin();        // 首结点

    while (curr != ilst.end())
    {
        if (*curr & 1)  // 奇数
        {
            curr = ilst.insert(curr, *curr); // 插入到当前元素之前
            curr++; curr++; // 移动到下一元素
        }
        else            // 偶数
        {
            curr = ilst.erase(curr);   // 删除，指向下一元素
        }
    }

    for (curr = ilst.begin(); curr != ilst.end(); curr++)
    {
        cout << *curr << " ";
    }
    cout << endl;

    return 0;
}
#include <iostream>
#include <algorithm>
#include <iterator>
#include "Sales_item.h"
using namespace ::std;

int main()
{
    vector<Sales_item> vs;
    istream_iterator<Sales_item> in_iter(cin);
    istream_iterator<Sales_item> eof;

    // 读入交易记录，存入vector
    while (in_iter != eof)
    {
        vs.push_back(*in_iter++);
    }

    if (vs.empty())
    {
        //没有输入！警告读者
        std::cerr << "No data?!" << std::endl;
        return -1; // 表示失败
    }

    // 将交易记录按ISBN号排序
    sort(vs.begin(), vs.end(), compareIsbn);

    auto l = vs.begin();
    while (l != vs.end())
    {
        auto item = *l;   // 相同ISBN的交易记录中第一个
        // 在后续记录中查找第一个ISBN与item不同者
        auto r = find_if(l + 1, vs.end(),
                         [item] (const Sales_item &item1) { return item1.isbn() != item.isbn(); } );
        // 将范围[l, r)间的交易记录累加并输出
        cout << accumulate(l + 1, r, item) << endl;
        // l指向下一段交易记录中的第一个
        l = r;
    }

    return 0;
}
#include <string>
using std::string;

#include <fstream>
using std::ifstream;

#include <iostream>
using std::cin;
using std::cout;
using std::cerr;
using std::endl;

#include <cstdlib>  // for EXIT_FAILURE
#include "my_TextQuery.h"
#include "make_plural.h"

void runQueries(ifstream &infile)
{
	// infile is an ifstream that is the file we want to query
    TextQuery tq(infile);  // store the file and build the query map
    // iterate with the user: prompt for a word to find and print results
    while (true)
    {
        cout << "enter word to look for, or q to quit: ";
        string s;
        // stop if we hit end-of-file on the input or if a 'q' is entered
        if (!(cin >> s) || s == "q")
        {
            break;
        }
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
    if (argc < 2 || !(infile.open(argv[1]), infile))
    {
        cerr << "No input file!" << endl;
        return EXIT_FAILURE;
    }
	runQueries(infile);
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

class Window_mgr
{
public:
    void clear();
};

class Screen
{
friend void Window_mgr::clear();
private:
	unsigned height = 0, width = 0;
	unsigned cursor = 0;
	string contents;
public:
	Screen() = default;	//榛樿鏋勯€犲嚱鏁?
	Screen(unsigned ht, unsigned wd, char c)
        : height(ht), width(wd), contents(ht * wd, c) { }
};

void Window_mgr::clear()
{
    Screen myScreen(10, 20, 'X');
    cout << "娓呯悊涔嬪墠myScreen鐨勫唴瀹规槸锛? << endl;
    cout << myScreen.contents << endl;
    myScreen.contents = "";
    cout << "娓呯悊涔嬪悗myScreen鐨勫唴瀹规槸锛? << endl;
    cout << myScreen.contents << endl;
}

int main()
{
    Window_mgr w;
    w.clear();
    return 0;
}
#include <iostream>
using namespace std;

int main()
{
    const int sz = 10;  //常量sz作为数组的维度
    int a[sz], b[sz];
    //通过for循环为数组元素赋值
    for (int i = 0; i < sz; i++)
    {
        a[i] = i;
    }
    for (int j = 0; j < sz; j++)
    {
        b[j] = a[j];
    }
    //通过范围for循环输出数组的全部元素
    for (auto val : b)
    {
        cout << val << " ";
    }
    cout << endl;

    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    const int sz = 10;  //常量sz作为vector的容量
    vector<int> vInt, vInt2;
    //通过for循环为vector对象的元素赋值
    for (int i = 0; i < sz; i++)
    {
        vInt.push_back(i);
    }
    for (int j = 0; j < sz; j++)
    {
        vInt2.push_back(vInt[j]);
    }
    //通过范围for循环输出vector对象的全部元素
    for (auto val : vInt2)
    {
        cout << val << " ";
    }
    cout << endl;

    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

//閫掑綊鍑芥暟杈撳嚭vector<int>鐨勫唴瀹?
void print(vector<int> vInt, unsigned index)
{
    unsigned sz = vInt.size();
    if (!vInt.empty() && index < sz)
    {
        cout << vInt[index] << endl;
        print(vInt, index + 1);
    }
}

int main()
{
    vector<int> v = {1, 3, 5, 7, 9, 11, 13, 15};
    print(v, 0);
    return 0;
}
#include <iostream>
#include <fstream>
#include <iterator>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    if (argc != 4)
    {
        cout << "用法：execise.exe in_file out_file1 out_file2" << endl;
        return -1;
    }

    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    ofstream out1(argv[2]);
    if (!out1)
    {
        cout << "打开输出文件1失败！" << endl;
        exit(1);
    }

    ofstream out2(argv[3]);
    if (!out2)
    {
        cout << "打开输出文件2失败！" << endl;
        exit(1);
    }

    // 创建流迭代器从文件读入整数
    istream_iterator<int> in_iter(in);
    // 尾后迭代器
    istream_iterator<int> eof;
    // 第一个输出文件以空格间隔整数
    ostream_iterator<int> out_iter1(out1, " ");
    // 第二个输出文件以换行间隔整数
    ostream_iterator<int> out_iter2(out2, "\n");
    while (in_iter != eof)
    {
        if (*in_iter & 1) // 奇数写入第一个输出文件
        {
            *out_iter1++ = *in_iter;
        }
        else
        {
            *out_iter2++ = *in_iter; // 偶数写入第二个输出文件
        }
        in_iter++;
    }

    return 0;
}
#include <map>
#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <stdexcept>
#include <sstream>

using std::map;
using std::string;
using std::vector;
using std::ifstream;
using std::cout;
using std::endl;
using std::getline;
using std::runtime_error;
using std::istringstream;

map<string, string> buildMap(ifstream &map_file)
{
    map<string, string> trans_map;   // holds the transformations
    string key;    // a word to transform
	string value;  // phrase to use instead
	// read the first word into key and the rest of the line into value
	while (map_file >> key && getline(map_file, value))
    {
		if (value.size() > 1) // check that there is a transformation
        {
        	trans_map[key] = value.substr(1); // skip leading space
        }
		else
        {
			throw runtime_error("no rule for " + key);
        }
    }
	return trans_map;
}

const string &transform(const string &s, const map<string, string> &m)
{
	// the actual map work; this part is the heart of the program
	auto map_it = m.find(s);
	// if this word is in the transformation map
	if (map_it != m.cend())
    {
		return map_it->second; // use the replacement word
    }
	else
    {
		return s;              // otherwise return the original unchanged
    }
}

// first argument is the transformations file;
// second is file to transform
void word_transform(ifstream &map_file, ifstream &input)
{
	auto trans_map = buildMap(map_file); // store the transformations

	// for debugging purposes print the map after its built
    cout << "Here is our transformation map: \n\n";
	for (auto entry : trans_map)
    {
        cout << "key: "   << entry.first << "\tvalue: " << entry.second << endl;
    }
    cout << "\n\n";

	// do the transformation of the given text
    string text;                    // hold each line from the input
    while (getline(input, text))  // read a line of input
    {
        istringstream stream(text); // read each word
        string word;
        bool firstword = true;      // controls whether a space is printed
        while (stream >> word)
        {
           if (firstword)
           {
               firstword = false;
           }
           else
           {
               cout << " ";  // print a space between words
           }
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
    {
        throw runtime_error("wrong number of arguments");
    }

    ifstream map_file(argv[1]); // open transformation file
    if (!map_file)              // check that open succeeded
    {
        throw runtime_error("no transformation file");
    }

    ifstream input(argv[2]);    // open file of text to transform
    if (!input)                 // check that open succeeded
    {
        throw runtime_error("no input file");
    }

	word_transform(map_file, input);

    return 0;  // exiting main will automatically close the files
}
#include <map>
#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <stdexcept>
#include <sstream>
#include <vector>
#include <random>
#include <time.h>
using namespace std;

map<string, vector<string>> buildMap(ifstream &map_file)
{
  // 允许多种转换方法
    map<string, vector<string>> trans_map;   // holds the transformations
    string key;    // a word to transform
  	string value;  // phrase to use instead
  	// read the first word into key and the rest of the line into value
  	while (map_file >> key && getline(map_file, value))
    {
    		if (value.size() > 1) // check that there is a transformation
        {
          	trans_map[key].push_back(value.substr(1)); // skip leading space
        }
    		else
        {
    		  	throw runtime_error("no rule for " + key);
        }
    }
  	return trans_map;
}

const string &transform(const string &s, const map<string, vector<string>> &m)
{
    static default_random_engine e(time(0));   // 随机数引擎，静态变量保持状态
  	// the actual map work; this part is the heart of the program
  	auto map_it = m.find(s);
  	// if this word is in the transformation map
  	if (map_it != m.cend())
    {
  	    // 随机数分布
        uniform_int_distribution<unsigned> u(0, map_it->second.size()-1);
  	   	return map_it->second[u(e)]; // 随机选择一种转换方式
  	}
  	else
    {
  	   	return s;              // otherwise return the original unchanged
    }
}

// first argument is the transformations file;
// second is file to transform
void word_transform(ifstream &map_file, ifstream &input)
{
	auto trans_map = buildMap(map_file); // store the transformations

     // for debugging purposes print the map after its built
    cout << "Here is our transformation map: \n\n";
    for (auto entry : trans_map)
    {
        cout << "key: "   << entry.first << "\tvalue: ";
        for (auto s : entry.second)
        {
            cout << s << ", ";
        }
        cout << endl;
    }
    cout << endl << endl;

    // do the transformation of the given text
    string text;                    // hold each line from the input
    while (getline(input, text))  // read a line of input
    {
        istringstream stream(text); // read each word
        string word;
        bool firstword = true;      // controls whether a space is printed
        while (stream >> word)
        {
            if (firstword)
            {
                firstword = false;
            }
            else
            {
                cout << " ";  // print a space between words
            }
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
    {
        throw runtime_error("wrong number of arguments");
    }

    ifstream map_file(argv[1]); // open transformation file
    if (!map_file)              // check that open succeeded
    {
        throw runtime_error("no transformation file");
    }

    ifstream input(argv[2]);    // open file of text to transform
    if (!input)                 // check that open succeeded
    {
        throw runtime_error("no input file");
    }

	  word_transform(map_file, input);
    return 0;  // exiting main will automatically close the files
}
#include <iostream>
using namespace std;

int main()
{
    int x = 10, y = 20;
    //检验条件为真的情况
    bool someValue = true;
    someValue ? ++x, ++y : --x, --y;
    cout << x << endl;
    cout << y << endl;
    cout << someValue << endl;

    x = 10, y = 20;
    //检验条件为假的情况
    someValue = false;
    someValue ? ++x, ++y : --x, --y;
    cout << x << endl;
    cout << y << endl;
    cout << someValue << endl;

    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        cout << "用法：execise.exe in_file" << endl;
        return -1;
    }

    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<int> vi;
    int v;
    while (in >> v)   // 从文件中读取整数
    {
        vi.push_back(v);
    }

    for (auto r_iter = vi.crbegin(); r_iter != vi.crend(); ++r_iter)
    {
        cout << *r_iter << " ";
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

#include <iostream>
#include <cmath>
#include <iomanip>

using namespace std;

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

  cout << 10.0 << endl; 		// 打印10
  cout << showpoint << 10.0 	// 打印10.0000
      << noshowpoint << endl; 	// 恢复小数点的默认格式

  cout << showpos << 10.0 << endl;  // 非负数打印+
  cout << noshowpos << 10.0 << endl; // 非负数不打印+


  cout << uppercase << showbase << hex
      << "printed in hexadecimal: " << 20 << " " << 1024
      << nouppercase << noshowbase << dec << endl;

  int i = -16;
  double d = 3.14159;
  // 补白第一列，使用输出中最小12个位置
  cout << "i: " << setw(12) << i << "next col" << '\n'
      << "d: " << setw(12) << d << "next col" << '\n';
  // 补白第一列，左对齐所有列
  cout << left
      << "i: " << setw(12) << i << "next col" << '\n'
      << "d: " << setw(12) << d << "next col" << '\n'
      << right; // 恢复正常对齐
  // 补白第一列，右对齐所有列
  cout << right
      << "i: " << setw(12) << i << "next col" << '\n'
      << "d: " << setw(12) << d << "next col" << '\n';
  // 补白第一列，但补在域的内部
  cout << internal
      << "i: " << setw(12) << i << "next col" << '\n'
      << "d: " << setw(12) << d << "next col" << '\n';
  // 补白第一列，用#作为补白字符
  cout << setfill('#')
      << "i: " << setw(12) << i << "next col" << '\n'
      << "d: " << setw(12) << d << "next col" << '\n'
      << setfill(' '); // 恢复正常的补白字符

  cout << unitbuf; 		// 所有输出操作后都会立即刷新缓冲区
  cout << "default format: " << 100 * sqrt(2.0) << '\n'
      << "scientific: " << scientific << 100 * sqrt(2.0) << '\n'
      << "fixed decimal: " << fixed << 100 * sqrt(2.0) << '\n'
      //<< "hexadecimal: " << hexfloat << 100 * sqrt(2.0) << '\n'
      //<< "use defaults: " << defaultfloat << 100 * sqrt(2.0)
      << "\n\n";
  cout << nounitbuf; 		// 回到正常的缓冲方式

  cout << "hi!" << endl;   	// 输出hi和一个换行，然后刷新缓冲区
  cout << "hi!" << flush; 	// 输出hi，然后刷新缓冲区，不附加任何额外字符
  cout << "hi!" << ends;   	// 输出hi和一个空字符，然后刷新缓冲区

  char ch;
  cin >> noskipws; // 设置cin读取空白符
  while (cin >> ch)
    cout << ch;
  cin >> skipws; // 将cin恢复到默认状态，从而丢弃空白符


  return 0;
}
#include <iostream>

int main()
{
    int i = 0, &r = i;
    auto a = r;     // a是个整数（r是i的别名，而i是个整数）
    const int ci = i, &cr = ci;
    auto b = ci;    // b 是一个整数（ci的顶层const特性被忽略掉了）
    auto c = cr;    // c是一个整数（cr是ci的别名，ci本身是个顶层const）
    auto d = &i;    // d是一个整型指针（整数的地址就是指向整数的指针）
    auto e = &ci;   // e是一个指向整型常量的指针（对常量对象取地址是一种底层const）
    auto &g = ci;   // g是一个整型常量引用，绑定到ci
    std::cout << a << " " << b << " " << c << " " << d << " " << e << " " << g << std::endl;

    a = 42;
    b = 42;
    c = 42;
    //d = 42;         //错误：d是一个指针，赋值非法
    //e = 42;         //错误：e是一个指针，赋值非法
    //g = 42;         //错误：g是一个常量引用，赋值非法
    std::cout << a << " " << b << " " << c << " " << d << " " << e << " " << g << std::endl;
    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
    vector<int> vi = {1,2,3,4,5,6,7,8,9};
    auto iter = vi.begin();
    string tmp;
    while (iter != vi.end())
    {
        if (*iter % 2)
        {
            iter = vi.insert(iter, *iter);
        }

        for (auto begin = vi.begin(); begin != vi.end(); begin++)
        {
            cout << *begin << " ";
        }
        cout << endl;
        cin >> tmp;
    }
    ++iter;

    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

int main()
{
  	vector<int> vi = {1,2,3,4,5,6,7,8,9};
    auto iter = vi.begin();
    string tmp;
    while (iter != vi.end())
    {
        if (*iter % 2)
        {
            iter = vi.insert(iter, *iter);
        }
        ++iter;

        for (auto begin = vi.begin(); begin != vi.end(); begin++)
        {
          cout << *begin << " ";
        }
        cout << endl;
        cin >> tmp;
    }

    return 0;
}
#include <iostream>
using namespace std;

int main()
{
    const int sz = 10;  //常量sz作为数组的维度
    int a[sz], i = 0;
    //通过for循环为数组元素赋值
    for (i = 0; i < 10; i++)
    {
        a[i] = i;
    }
    cout << "初始状态下数组的内容是：" << endl;
    for (auto val : a)
    {
        cout << val << " ";
    }
    cout << endl;

    int *p = begin(a);  //令p指向数组首元素
    while (p != end(a))
    {
        *p = 0;         //修改p所指元素的值
        p++;            //p向后移动一位
    }
    cout << "修改后的数组内容是：" << endl;
    //通过范围for循环输出数组的全部元素
    for (auto val : a)
    {
        cout << val << " ";
    }
    cout << endl;

    return 0;
}

#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        cout << "用法：execise.exe in_file" << endl;
        return -1;
    }

    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<int> vi;
    int v;
    while (in >> v)   // 从文件中读取整数
    {
        vi.push_back(v);
    }

    for (auto r_iter = vi.cend(); r_iter != vi.begin();)
    {
        cout << *(--r_iter) << " ";
    }
    cout << endl;
    return 0;
}
#include <iostream>
#include<typeinfo>

int main()
{
    const int i = 42;
    auto j = i;
    const auto &k = i;
    auto *p = &i;
    const auto j2 = i, &k2 = i;
    std::cout << typeid(i).name() << std::endl;
    std::cout << typeid(j).name() << std::endl;
    std::cout << typeid(k).name() << std::endl;
    std::cout << typeid(p).name() << std::endl;
    std::cout << typeid(j2).name() << std::endl;
    std::cout << typeid(k2).name() << std::endl;
    return 0;
}
#include <iostream>
#include <list>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    list<int> li = { 0, 1, 2, 0, 3, 4, 5, 0, 6 };
    // 用普通迭代器查找第一个0的位置
    auto prev = find(li.begin(), li.end(), 0);
    if (prev == li.end())   // 未找到
    {
        cout << "容器中没有0" << endl;
    }
    else
    {
        auto curr = prev;
        // 继续寻找后续0，直到到达尾后位置
        while (curr != li.end())
        {
            // 记住上一个0的位置
            prev = curr;
            curr++;
            // 寻找下一个0
            curr = find(curr, li.end(), 0);
        }
        // 从链表头开始计数prev的位置编号
        int p = 1;
        for (auto iter = li.begin(); iter != prev; iter++, p++)
        {
        }

        cout << "最后一个0在第" << p << "个位置" << endl;
    }

    return 0;
}
#include <iostream>
#include <ctime>
#include <cstdlib>
using namespace std;

int main()
{
    const int sz = 5;  //常量sz作为数组的维度
    int a[sz], b[sz], i;
    srand((unsigned) time(NULL));    //生成随机数种子
    //通过for循环为数组元素赋值
    for (i = 0; i < sz; i++)
    {
        //每次循环生成一个10以内的随机数并添加到a中
        a[i] = rand() % 10;
    }

    cout << "系统数据已经生成，请输入您猜测的5个数字（0~9），可以重复：" << endl;
    int uVal;
    //通过for循环为数组元素赋值
    for (i = 0; i < sz; i++)
    {
        if (cin >> uVal)
        {
            b[i] = uVal;
        }
    }

    cout << "系统生成的数据是：" << endl;
    for (auto val : a)
    {
        cout << val << " ";
    }
    cout << endl;

    cout << "您猜测的数据是：" << endl;
    for (auto val : b)
    {
        cout << val << " ";
    }
    cout << endl;

    int *p = begin(a), *q = begin(b);  //令p,q分别指向数组a和b的首元素
    while (p != end(a) && q != end(b))
    {
        if (*p != *q)
        {
            cout << "您的猜测错误，两个数组不相等" << endl;
            return -1;
        }
        p++;            //p向后移动一位
        q++;            //q向后移动一位
    }
	cout << "恭喜您全都猜对了！" << endl;

    return 0;
}
#include <iostream>
#include <list>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    list<int> li = { 0, 1, 2, 0, 3, 4, 5, 0, 6};
    // 利用反向迭代器查找最后一个0
    auto last_z = find(li.rbegin(), li.rend(), 0);
    // 将迭代器向链表头方向推进一个位置
    // 转换为普通迭代器时，将回到最后一个0的位置
    last_z++;
    int p = 1;
    // 用base将last_z转换为普通迭代器
    // 从链表头开始遍历，计数最后一个0的编号
    for (auto iter = li.begin(); iter != last_z.base(); iter++, p++)
    {
    }

    if (p >= li.size())   // 未找到0
    {
        cout << "容器中没有0" << endl;
    }
    else
    {
        cout << "最后一个0在第" << p << "个位置" << endl;
    }

    return 0;
}
#include <iostream>
#include <ctime>
#include <cstdlib>
#include <vector>
using namespace std;

int main()
{
    const int sz = 5;  //常量sz作为vector的容量
    int i;
    vector<int> a, b;
    srand((unsigned) time(NULL));    //生成随机数种子
    //通过for循环为数组元素赋值
    for (i = 0; i < sz; i++)
    {
        //每次循环生成一个10以内的随机数并添加到a中
        a.push_back(rand() % 10);
    }

    cout << "系统数据已经生成，请输入您猜测的5个数字（0~9），可以重复：" << endl;
    int uVal;
    //通过for循环为数组元素赋值
    for (i = 0; i < sz; i++)
    {
        if (cin >> uVal)
        {
            b.push_back(uVal);
        }
    }

    cout << "系统生成的数据是：" << endl;
    for (auto val : a)
    {
        cout << val << " ";
    }
    cout << endl;

    cout << "您猜测的数据是：" << endl;
    for (auto val : b)
    {
        cout << val << " ";
    }
    cout << endl;

	//令it1,it2分别指向vector对象a和b的首元素
    auto it1 = a.cbegin(), it2 = b.cbegin();
    while (it1 != a.cend() && it2 != b.cend())
    {
        if (*it1 != *it2)
        {
            cout << "您的猜测错误，两个vector不相等" << endl;
            return -1;
        }
        it1++;            //p向后移动一位
        it2++;            //q向后移动一位
    }
	cout << "恭喜您全都猜对了！" << endl;

    return 0;
}
#include <vector>
#include <algorithm>
using namespace std;

class IntCompare
{
public:
	IntCompare(int v) : val(v) {}
	bool operator()(int v) { return val == v; }
private:
	int val;
};

int main()
{
	vector<int> vec = {1, 2, 3, 2, 1};
	const int oldValue = 2;
	const int newValue = 200;
	IntCompare icmp(oldValue);
	std::replace_if(vec.begin(), vec.end(), icmp, newValue);

	return 0;
}
#include <iostream>
#include <fstream>

using namespace std;

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        cerr << "Usage: execise infile_name" << endl;
        return -1;
    }

    ifstream in(argv[1]);
    if (!in)
    {
        cerr << "Can not open input file" << endl;
        return -1;
    }

    char text[50];
    while (!in.eof())
    {
        in.getline(text, 30);
        cout << text << endl;
        //cout << in.gcount() << endl;
        if (!in.good())
        {
            if (in.gcount() == 29)
            {
                in.clear();
            }
            else
            {
                break;
            }
        }
    }

    return 0;
}
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
#include <iostream>
#include <vector>
#include <list>
#include <iterator>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ostream_iterator<int> out_iter(cout, " ");
    vector<int> vi = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    // 用流迭代器和copy输出int序列
    copy(vi.begin(), vi.end(), out_iter);
    cout << endl;

    list<int> li;
    // 将vi[2]，也就是第三个元素的位置转换为反向迭代器
    vector<int>::reverse_iterator re(vi.begin() + 2);
    // 将vi[7]，也就是第八个元素的位置转换为反向迭代器
    vector<int>::reverse_iterator rb(vi.begin() + 7);
    // 用反向迭代器将元素逆序拷贝到list
    copy(rb, re, back_inserter(li));
    copy(li.begin(), li.end(), out_iter);
    cout << endl;
    return 0;
}
#include <iostream>
#include <vector>
#include <list>
#include <iterator>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ostream_iterator<int> out_iter(cout, " ");
    vector<int> vi = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    copy(vi.begin(), vi.end(), out_iter);
    cout << endl;

    list<int> li;
    copy(vi.rbegin() + vi.size() - 7, vi.rbegin() + vi.size() - 3 + 1, back_inserter(li));
    copy(li.begin(), li.end(), out_iter);
    cout << endl;
    return 0;
}

#include <iostream>
#include <vector>
using namespace std;

int main()
{
  	vector<int> vi;
  	int s, c;

    for (s = vi.size(), c = vi.capacity(); s <= c; s++)
    {
        vi.push_back(1);
    }
    cout << "空间：" << vi.capacity() << "，元素数：" << vi.size() << endl;

    for (s = vi.size(), c = vi.capacity(); s <= c; s++)
    {
        vi.push_back(1);
    }
    cout << "空间：" << vi.capacity() << "，元素数：" << vi.size() << endl;

    for (s = vi.size(), c = vi.capacity(); s <= c; s++)
    {
        vi.push_back(1);
    }
    cout << "空间：" << vi.capacity() << "，元素数：" << vi.size() << endl;

    for (s = vi.size(), c = vi.capacity(); s <= c; s++)
    {
        vi.push_back(1);
    }
    cout << "空间：" << vi.capacity() << "，元素数：" << vi.size() << endl;

    for (s = vi.size(), c = vi.capacity(); s <= c; s++)
    {
        vi.push_back(1);
    }
    cout << "空间：" << vi.capacity() << "，元素数：" << vi.size() << endl;

    return 0;
}
#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

class StrLenIs
{
public:
	StrLenIs(int len) : len(len) {}
	bool operator()(const string &str) { return str.length() == len; }

private:
	int len;
};

void readStr(istream &is, vector<string> &vec)
{
	string word;
	while (is >> word)
	{
		vec.push_back(word);
	}
}

int main()
{
	vector<string> vec;
	readStr(cin, vec);
	const int minLen = 1;
	const int maxLen = 10;
	for (int i = minLen; i <= maxLen; i++)
	{
		StrLenIs slenIs(i);
		cout << "len : " << i << ", cnt : " << count_if(vec.begin(), vec.end(), slenIs) << endl;
	}

	return 0;
}
#include <iostream>
#include <fstream>

using namespace std;

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        cerr << "Usage: execise infile_name" << endl;
        return -1;
    }

    ifstream in(argv[1]);
    if (!in)
    {
        cerr << "Can not open input file" << endl;
        return -1;
    }

    char text[50];
    while (!in.eof())
    {
        in.getline(text, 30);
        cout << text;
        if (!in.good())
        {
            if (in.gcount() == 29)
            {
                in.clear();
            }
            else
            {
                break;
            }
        }
        else
        {
            cout << endl;
        }
    }

    return 0;
}
#include <iostream>
#include <typeinfo>

int main()
{
    int a = 3;
    auto c1 = a;
    decltype(a) c2 = a;
    decltype((a)) c3 = a;

    const int d = 5;
    auto f1 = d;
    decltype(d) f2 = d;

    std::cout << typeid(c1).name() << std::endl;
    std::cout << typeid(c2).name() << std::endl;
    std::cout << typeid(c3).name() << std::endl;
    std::cout << typeid(f1).name() << std::endl;
    std::cout << typeid(f2).name() << std::endl;

    c1++;
    c2++;
    c3++;
    f1++;
    //f2++;		//错误：f2是整型常量，不能执行自增操作
    std::cout << a << " " << c1 << " " << c2 << " " << c3 << " " << f1 << " " << f2 << std::endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <unordered_map>
#include <string>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    unordered_map<string, size_t> word_count; // string到count的映射
    string word;
    while (in >> word)
    {
        ++word_count[word];   // 这个单词的出现次数加1
    }

  	for (const auto &w : word_count) 	// 对map中的每个元素
    {
  	   	cout << w.first << "出现了" << w.second << "次" << endl;
    }
    return 0;
}
#include <unordered_map>
#include <vector>
#include <iostream>
#include <fstream>
#include <string>
#include <stdexcept>
#include <sstream>
using std::unordered_map; using std::string; using std::vector;
using std::ifstream; using std::cout; using std::endl;
using std::getline;
using std::runtime_error; using std::istringstream;

unordered_map<string, string> buildMap(ifstream &map_file)
{
    unordered_map<string, string> trans_map;   // holds the transformations
    string key;    // a word to transform
	string value;  // phrase to use instead
	// read the first word into key and the rest of the line into value
	while (map_file >> key && getline(map_file, value))
    {
		if (value.size() > 1) // check that there is a transformation
        {
        	trans_map[key] = value.substr(1); // skip leading space
        }
		else
        {
			throw runtime_error("no rule for " + key);
        }
    }
	return trans_map;
}

const string &transform(const string &s, const unordered_map<string, string> &m)
{
	// the actual map work; this part is the heart of the program
	auto map_it = m.find(s);
	// if this word is in the transformation map
	if (map_it != m.cend())
    {
		return map_it->second; // use the replacement word
    }
	else
    {
		return s;              // otherwise return the original unchanged
    }
}

// first argument is the transformations file;
// second is file to transform
void word_transform(ifstream &map_file, ifstream &input)
{
	auto trans_map = buildMap(map_file); // store the transformations

	// for debugging purposes print the map after its built
    cout << "Here is our transformation map: \n\n";
	for (auto entry : trans_map)
    {
        cout << "key: "   << entry.first << "\tvalue: " << entry.second << endl;
    }
    cout << "\n\n";

	// do the transformation of the given text
    string text;                    // hold each line from the input
    while (getline(input, text))  // read a line of input
    {
        istringstream stream(text); // read each word
        string word;
        bool firstword = true;      // controls whether a space is printed
        while (stream >> word)
        {
            if (firstword)
            {
                firstword = false;
            }
            else
            {
                cout << " ";  // print a space between words
            }
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
    {
        throw runtime_error("wrong number of arguments");
    }

    ifstream map_file(argv[1]); // open transformation file
    if (!map_file)              // check that open succeeded
    {
        throw runtime_error("no transformation file");
    }

    ifstream input(argv[2]);    // open file of text to transform
    if (!input)                 // check that open succeeded
    {
        throw runtime_error("no input file");
    }

	word_transform(map_file, input);
    return 0;  // exiting main will automatically close the files
}
#include <string>
#include <vector>
#include <algorithm>
#include <iostream>
using namespace std;

class StrLenBetween
{
public:
	StrLenBetween(int minLen, int maxLen) : minLen(minLen), maxLen(maxLen) {}
	bool operator()(const string &str)
	{
		return str.length() >= minLen && str.length() <= maxLen;
	}

private:
	int minLen;
	int maxLen;
};

class StrNotShorterThan
{
public:
	StrNotShorterThan(int len) : minLen(len) {}
	bool operator()(const string &str) { return str.length() >= minLen; }

private:
	int minLen;
};

extern readStr(istream &is, vector<string> &vec);  // 浣跨敤涓婁竴棰樼洰涓殑鍑芥暟

int main()
{
	vector<string> vec;
	readStr(cin, vec);

	StrLenBetween slenBetween(1, 9);
	StrNotShorterThan sNotShorterThan(10);
	cout << "len 1~9 : " << count_if(vec.begin(), vec.end(), slenBetween) << endl;
	cout << "len >= 10 : " << count_if(vec.begin(), vec.end(), sNotShorterThan) << endl;

	return 0;
}
#include <iostream>
using std::cerr; using std::endl;

#include <fstream>
using std::fstream;

#include <string>
using std::string;

#include <cstdlib> // for EXIT_FAILURE

int main(int argc, char *argv[])
{
    // open for input and output and preposition file pointers to end-of-file
	// file mode argument
    fstream inOut(argv[1], fstream::ate | fstream::in | fstream::out);
    if (!inOut)
    {
        cerr << "Unable to open file!" << endl;
        return EXIT_FAILURE; // EXIT_FAILURE
    }

    // inOut is opened in ate mode, so it starts out positioned at the end
    auto end_mark = inOut.tellg();// remember original end-of-file position
    inOut.seekg(0, fstream::beg); // reposition to the start of the file
    size_t cnt = 0;               // accumulator for the byte count
    string line;                  // hold each line of input

    // while we haven't hit an error and are still reading the original data
    while (inOut && inOut.tellg() != end_mark && getline(inOut, line)) // and can get another line of input
    {
        std::cout << line << ":" << line.size() << std::endl;
        cnt += line.size() + 1;       // add 1 to account for the newline
		auto mark = inOut.tellg();    // remember the read position
		std::cout << mark << endl;
        inOut.seekp(0, fstream::end); // set the write marker to the end
        inOut << cnt;                 // write the accumulated length
        // print a separator if this is not the last line
        if (mark != end_mark)
        {
            inOut << " ";
        }
        inOut.seekg(mark);            // restore the read position
    }
    inOut.seekp(0, fstream::end);     // seek to the end
    inOut << "\n";                    // write a newline at end-of-file

    return 0;
}
#include "StrVec.h"

#include <string>
using std::string;

#include <iostream>
using std::cout;
using std::endl;
using std::istream;

#include <fstream>
using std::ifstream;

void print(const StrVec &svec)
{
	for (auto it : svec)
    {
		cout << it << " " ;
    }
	cout <<endl;
}

StrVec getVec(istream &is)
{
	StrVec svec;
	string s;
	while (is >> s)
    {
		svec.push_back(s);
    }
	return svec;
}

int main()
{
	StrVec sv = {"one", "two", "three"};
	// run the string empty funciton on the first element in sv
	if (!sv[0].empty())
    {
		sv[0] = "None"; // assign a new value to the first string
    }

	// we'll call getVec a couple of times
	// and will read the same file each time
	ifstream in("storyDataFile");
	StrVec svec = getVec(in);
	print(svec);
	in.close();

	cout << endl << "copy " << svec.size() << endl;
	auto svec2 = svec;
	print(svec2);

	cout << endl << "assign" << endl;
	StrVec svec3;
	svec3 = svec2;
	print(svec3);

	StrVec v1, v2;
	v1 = v2;                   // v2 is an lvalue; copy assignment

	in.open("storyDataFile");
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

    cout << endl << "capacity: " << sv.capacity() << endl;
    cout << "reserve..." << endl;
    sv.reserve(sv.capacity() * 3);
    cout << "new capacity: " << sv.capacity() << endl;
    sv.push_back("four");
    print(sv);

    cout << endl << "size: " << sv.size() << endl;
    cout << "resize 6..." << endl;
    sv.resize(6, "max");
    cout << "new size: " << sv.size() << endl;
    print(sv);
    cout << "resize 2..." << endl;
    sv.resize(2);
    cout << "new size: " << sv.size() << endl;
    print(sv);

	return 0;
}

#include <iostream>
#include <string>
using namespace std;

int main()
{
    string str1, str2;
    cout << "请输入两个字符串：" << endl;
    cin >> str1 >> str2;

    if (str1 > str2)
    {
        cout << "第一个字符串大于第二个字符串" << endl;
    }
    else if (str1 < str2)
    {
        cout << "第一个字符串小于第二个字符串" << endl;
    }
    else
    {
        cout << "两个字符串相等" <<endl;
    }
    return 0;
}
#include <iostream>
#include <cstring>
using namespace std;

int main()
{
    char str1[80], str2[80];
    cout << "请输入两个字符串：" << endl;
    cin >> str1 >> str2;
    //利用cstring头文件定义的strcmp函数比较大小
    auto result = strcmp(str1, str2);
    switch (result)
    {
    case 1:
        cout << "第一个字符串大于第二个字符串" << endl;
        break;
    case -1:
        cout << "第一个字符串小于第二个字符串" << endl;
        break;
    case 0:
        cout << "两个字符串相等" <<endl;
        break;
    default:
        cout << "未定义的结果" << endl;
        break;
    }

    return 0;
}
#include <iostream>
using namespace std;

int fact(int val)
{
    if (val < 0)
    {
        return -1;
    }

    int ret = 1;
    //从1连乘到val
    for (int i = 1; i != val + 1; ++i)
    {
        ret *= i;
    }
    return ret;
}

int main()
{
    int num;
    cout << "请输入一个整数：";
    cin >> num;
    cout << num << "的阶乘是：" << fact(num) << endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
using namespace std;

int main()
{
    ifstream in("data");          // 打开文件
    if (!in)
    {
        cerr << "无法打开输入文件" << endl;
        return -1;
    }

    string line;
    vector<string> words;
    while (getline(in, line))   // 从文件中读取一行
    {
        words.push_back(line);      // 添加到vector中
    }

    in.close();                   // 输入完毕，关闭文件

    vector<string>::const_iterator it = words.begin();  // 迭代器
    while (it != words.end())  // 遍历vector
    {
        cout << *it << endl;        // 输出vector中元素
        ++it;
    }

    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

bool search_vec(vector<int>::iterator beg, vector<int>::iterator end, int val)
{
    for (; beg != end; beg++)    // 遍历范围
    {
        if (*beg == val)          // 检查是否与给定值相等
        {
            return true;
        }
    }
    return false;
}

int main()
{
    vector<int> ilist = {1, 2, 3, 4, 5, 6, 7};
    cout << search_vec(ilist.begin(), ilist.end(), 3) << endl;
    cout << search_vec(ilist.begin(), ilist.end(), 8) << endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<double> vd;
    double val;
    while (in >> val)
    {
        vd.push_back(val);
    }

    cout << "序列中浮点数之和为" << accumulate(vd.begin(), vd.end(), 0) << endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <map>
#include <string>
#include <algorithm>
using namespace std;

string &trans(string &s)
{
    for (int p = 0; p < s.size(); p++)
    {
        if (s[p] >= 'A' && s[p] <= 'Z')
        {
            s[p] -= ('A' - 'a');
        }
        else if (s[p] == ',' || s[p] == '.')
        {
            s.erase(p, 1);
        }
    }
    return s;
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    map<string, size_t> word_count;
    string word;
    while (in >> word)
    {
        ++word_count[trans(word)];
    }

  	for (const auto &w : word_count)
    {
  	   	cout << w.first << "出现了" << w.second << "次" << endl;
    }
    return 0;
}
#include <iostream>
#include <string>
#include <vector>
#include <list>
using namespace std;

template <typename I, typename T>
I find(I b, I e, const T &v)
{
    while (b != e && *b != v)
    {
        b++;
    }
    return b;
}

int main()
{
    vector<int> vi = { 0, 2, 4, 6, 8, 10 };
    list<string> ls = { "Hello", "World", "!" };

    auto iter = find(vi.begin(), vi.end(), 6);
    if (iter == vi.end())
    {
        cout << "can not find 6" << endl;
    }
    else
    {
        cout << "find 6 at position " << iter - vi.begin() << endl;
    }

    auto iter1 = find(ls.begin(), ls.end(), "mom");
    if (iter1 == ls.end())
    {
        cout << "can not find mom" << endl;
    }
    else
    {
        cout << "found mom" << endl;
    }

    return 0;
}

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
	for (auto it = files.cbegin(); it != files.cend(); ++it)
	{
		// find the range of Sales_data that have the same ISBN
		auto found = equal_range(it->cbegin(), it->cend(),
		                         book, compareIsbn);
		if (found.first != found.second)  // this store had sales
		{
			// remember the index of this store and the matching range
			ret.push_back(make_tuple(it - files.cbegin(), found.first, found.second));
		}
	}
	return ret; // empty if no matches found
}

vector<Sales_data> build_store(const string &s)
{
	Sales_data item;
	vector<Sales_data> ret;
	ifstream is(s);
	while (read(is, item))
	{
		ret.push_back(item);
	}
	sort (ret.begin(), ret.end(), lt);  // need sort for equal_range to work
	return ret;
}

void reportResults(istream &in, ostream &os, const vector<vector<Sales_data>> &files)
{
	string s;   // book to look for
	while (in >> s)
	{
		auto trans = findBook(files, s);  // stores that sold this book
		if (trans.empty())
		{
			cout << s << " not found in any stores" << endl;
			continue;  // get the next book to look for
		}
		for (const auto &store : trans)   // for every store with a sale
		{
			// get<n> returns the specified member from the tuple in store
			os << "store " << get<0>(store) << " sales: "
			   << accumulate(get<1>(store), get<2>(store), Sales_data(s))
			   << endl;
		}
	}
}

int main(int argc, char **argv)
{
	assert(argc > 1);
	// each element in files holds the transactions for a particular store
	vector<vector<Sales_data>> files;
	for (int cnt = 1; cnt != argc; ++cnt)
	{
		files.push_back(build_store(argv[cnt]));
	}

	ifstream in("findbook.in");  // ISBNs to search for
	reportResults(in, cout, files);
}
#include <iostream>
#include <typeinfo>
using namespace std;

class A
{
public:
    A() {}
    virtual ~A() {}
};

class B : public A
{
public:
    B() {}
    virtual ~B() {}
};

class C : public B
{
public:
    C() {}
    virtual ~C() {}
};

int main()
{
    A *pa = new A;
    try
    {
        C &c = dynamic_cast<C&>(*pa);
    }
    catch (bad_cast &bc)
    {
        cout << "dynamic_cast failed, and the error message is : " << bc.what() << endl;
    }
    return 0;
}
#include <iostream>

int main()
{
    std::cout << "请输入两个数" << std::endl;
    int v1, v2;
    std::cin >> v1 >> v2;
    std::cout << v1 << "和" << v2 << "的积为" << v1 * v2 << std::endl;
    return 0;
}
#include <iostream>
#include <cstring>
using namespace std;

int main()
{
    char str1[] = "Welcome to ";
    char str2[] = "C++ family!";
    //利用strlen函数计算两个字符串的长度，并求得结果字符串的长度
    char result[strlen(str1) + strlen(str2) - 1];

    strcpy(result, str1);   //把第一个字符串拷贝到结果字符串中
    strcat(result, str2);   //把第二个字符串拼接到结果字符串中

    cout << "第一个字符串是：" << str1 << endl;
    cout << "第二个字符串是：" << str2 << endl;
    cout << "拼接后的字符串是：" << result << endl;
    return 0;
}
#include <iostream>
#include <vector>
#include <ctime>
#include <cstdlib>
using namespace std;

int main()
{
    const int sz = 10;  //常量sz作为数组的维度
    int a[sz];
    srand((unsigned) time(NULL)); //生成随机数种子
    cout << "数组的内容是：" << endl;
    //利用范围for循环遍历数组的每个元素
    for (auto &val : a)
    {
        val = rand() % 100;   //生成一个100以内的随机数
        cout << val << " ";
    }
    cout << endl;

    //利用begin和end初始化vector对象
    vector<int> vInt(begin(a), end(a));
    cout << "vector的内容是：" << endl;
    //利用范围for循环遍历vector的每个元素
    for (auto val : vInt)
    {
        cout << val << " ";
    }
    cout << endl;
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

class Sales_data
{
    friend std::istream &read(std::istream &is, Sales_data &item);
    friend std::ostream &print(std::ostream &os, const Sales_data &item);
public:		//委托构造函数
    Sales_data(const string &book, unsigned num, double sellp, double salep)
                : bookNo(book), units_sold(num), sellingprice(sellp), saleprice(salep)
    {
        if(sellingprice)
        {
            discount = saleprice / sellingprice;
        }
        cout << "该构造函数接受书号、销售量、原价、实际售价四个信息" << endl;
    }
    Sales_data() : Sales_data("", 0, 0, 0) { cout << "该构造函数无需接受任何信息" << endl; }
    Sales_data(const string &book) : Sales_data(book, 0, 0, 0) { cout << "该构造函数接受书号信息" << endl; }
    Sales_data(std::istream &is) : Sales_data()
    {
        read(is, *this);
        cout << "该构造函数接受用户输入的信息" << endl;
    }

private:
    std::string bookNo;     	//书籍编号，隐式初始化为空串
    unsigned units_sold = 0; 	//销售量，显式初始化为0
    double sellingprice = 0.0;	//原始价格，显式初始化为0.0
	double saleprice = 0.0;		//实售价格，显式初始化为0.0
	double discount = 0.0;		//折扣，显式初始化为0.0
};

std::istream &read(std::istream &is, Sales_data &item)
{
    is >> item.bookNo >> item.units_sold >> item.sellingprice >> item.saleprice;
    return is;
}

std::ostream &print(std::ostream &os, const Sales_data &item)
{
    os << item.bookNo << " " << item.units_sold << " " << item.sellingprice << " " <<item.saleprice << " " << item.discount;
    return os;
}

int main()
{
    Sales_data fist("978-7-121-15535-2", 85, 128, 109);
    Sales_data second;
    Sales_data third("978-7-121-15535-2");
    Sales_data last(cin);
    return 0;
}
#include <iostream>
#include <vector>
#include <string>
using namespace std;

int main()
{
	vector<char> vc = {'H', 'e', 'l', 'l', 'o'};
	string s(vc.data(), vc.size());
	cout << s << endl;
    return 0;
}
#include <iostream>
using namespace std;

template <typename T1, typename T2>
auto sum(T1 a, T2 b) -> decltype(a + b)
{
    return a + b;
}

int main()
{
    auto a = sum(1, 1);
    cout << a << " " << sizeof(a) << endl;
    auto b = sum(1, 1.1);
    cout << b << " " << sizeof(b) << endl;
    auto c = sum(1, 1.1f);
    cout << c << " " << sizeof(c) << endl;

    return 0;
}
#include <iostream>
#include <string>

using namespace std;

class Sales_data
{
    friend std::istream& operator>>(std::istream&, Sales_data&);		//友元函数
    friend std::ostream& operator<<(std::ostream&, const Sales_data&);//友元函数
    friend bool operator<(const Sales_data&, const Sales_data&);		//友元函数
    friend bool operator==(const Sales_data&, const Sales_data&);		//友元函数
public:		//构造函数的3种形式
    Sales_data() = default;
    Sales_data(const std::string &book) : bookNo(book) {}
    Sales_data(std::istream &is) { is >> *this; }
public:
    Sales_data& operator+=(const Sales_data&);
    std::string isbn() const { return bookNo; }
private:
    std::string bookNo;     	//书籍编号，隐式初始化为空串
    unsigned units_sold = 0; 	//销售量，显式初始化为0
    double sellingprice = 0.0;	//原始价格，显式初始化为0.0
	double saleprice = 0.0;		//实售价格，显式初始化为0.0
	double discount = 0.0;		//折扣，显式初始化为0.0
};

inline bool compareIsbn(const Sales_data &lhs, const Sales_data &rhs)
{
    return lhs.isbn() == rhs.isbn();
}

Sales_data operator+(const Sales_data&, const Sales_data&);

inline bool operator==(const Sales_data &lhs, const Sales_data &rhs)
{
    return lhs.units_sold == rhs.units_sold &&
           lhs.sellingprice == rhs.sellingprice &&
           lhs.saleprice == rhs.saleprice &&
           lhs.isbn() == rhs.isbn();
}

inline bool operator!=(const Sales_data &lhs, const Sales_data &rhs)
{
    return !(lhs == rhs); 	//基于运算符==给出!=的定义
}

Sales_data& Sales_data::operator+=(const Sales_data& rhs)
{
    units_sold += rhs.units_sold;
    saleprice = (rhs.saleprice * rhs.units_sold + saleprice * units_sold) / (rhs.units_sold + units_sold);
    if (sellingprice != 0)
    {
        discount = saleprice / sellingprice;
    }
    return *this;
}

Sales_data operator+(const Sales_data& lhs, const Sales_data& rhs)
{
    Sales_data ret(lhs);  	//把lhs的内容拷贝到临时变量ret中，这种做法便于运算
    ret += rhs;           	//把rhs的内容加入其中
    return ret;           	//返回ret
}

std::istream& operator>>(std::istream& in, Sales_data& s)
{
    in >> s.bookNo >> s.units_sold >> s.sellingprice >> s.saleprice;
    if (in && s.sellingprice != 0)
    {
        s.discount = s.saleprice / s.sellingprice;
    }
    else
    {
        s = Sales_data();  	//输入错误，重置输入的数据
    }
    return in;
}

std::ostream& operator<<(std::ostream& out, const Sales_data& s)
{
    out << s.isbn() << " " << s.units_sold << " "
        << s.sellingprice << " " << s.saleprice << " " << s.discount;
    return out;
}

int main()
{
    Sales_data book;
    std::cout << "请输入销售记录："<< std::endl;
    while (std::cin >> book)
    {
        std::cout << " ISBN、售出本数、原始价格、原始价格、实售价格、折扣为" << book << std::endl;
    }

    Sales_data trans1, trans2;
    std::cout << "请输入两条ISBN相同的销售记录："<< std::endl;
    std::cin.clear(); // 清空输入流的错误状态标志位，以便后面继续输入。
    std::cin >> trans1 >> trans2;
    if (compareIsbn(trans1, trans2))
    {
        std::cout << "汇总信息：ISBN、售出本数、原始价格、实售价格、折扣为 " << trans1 + trans2 << std::endl;
    }
    else
    {
        std::cout << "两条销售记录的ISBN不同" << std::endl;
    }

    Sales_data total, trans;
    std::cout << "请输入几条ISBN相同的销售记录："<< std::endl;
    std::cin.clear(); // 清空输入流的错误状态标志位，以便后面继续输入。
    if (std::cin >> total)
    {
        while (std::cin >> trans)
        {
            if (compareIsbn(total, trans)) // ISBN 相同
            {
                total = total + trans;
            }
            else // ISBN 不同
            {
                std::cout << "当前书籍ISBN不同" << std::endl;
                break;
            }
        }
        std::cout << "有效汇总信息：ISBN、售出本数、原始价格、实售价格、折扣为" << total << std::endl;
    }
    else
    {
        std::cout << "没有数据" << std::endl;
        return -1;
    }

    int num = 1;    //记录当前书籍的销售记录总数
    std::cout << "请输入若干销售记录："<< std::endl;
    std::cin.clear();  // 清空输入流的错误状态标志位，以便后面继续输入。
    if (std::cin >> trans1)
    {
        while (std::cin >> trans2)
        {
            if (compareIsbn(trans1, trans2)) // ISBN 相同
            {
                num++;
            }
            else // ISBN 不同
            {
                std::cout << trans1.isbn() << "共有" << num << "条销售记录" << std::endl;
                trans1 = trans2;
                num = 1;
            }
        }
        std::cout << trans1.isbn() << "共有" << num << "条销售记录" << std::endl;
    }
    else
    {
        std::cout << "没有数据" << std::endl;
        return -1;
    }

    return 0;
}
#include <iostream>
#include <vector>
#include <ctime>
#include <cstdlib>
using namespace std;

int main()
{
    const int sz = 10;  //常量sz作为vector对象的容量
    vector<int> vInt;
    srand((unsigned) time(NULL)); //生成随机数种子
    cout << "vector对象的内容是：" << endl;
    //利用for循环遍历vector对象的每个元素
    for (int i = 0; i != sz; i++)
    {
        vInt.push_back(rand() % 100);   //生成一个100以内的随机数
        cout << vInt[i] << " ";
    }
    cout << endl;

    auto it = vInt.cbegin();
    int a[vInt.size()];
    cout << "数组的内容是：" << endl;
    //利用范围for循环遍历数组的每个元素
    for (auto &val : a)
    {
        val = *it;
        cout << val << " ";
        it++;
    }
    cout << endl;
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

//鏈€鍚庝竴涓舰鍙傝祴浜堜簡榛樿瀹炲弬
string make_plural(size_t ctr, const string &word, const string &ending = "s")
{
    return (ctr > 1) ? word + ending : word;
}

int main()
{
    cout << "success鐨勫崟鏁板舰寮忔槸锛? << make_plural(1, "success", "es") << endl;
    cout << "success鐨勫鏁板舰寮忔槸锛? << make_plural(2, "success", "es") << endl;
	//涓€鑸儏鍐典笅璋冪敤璇ュ嚱鏁板彧闇€瑕佷袱涓疄鍙?
    cout << "failure鐨勫崟鏁板舰寮忔槸锛? << make_plural(1, "failure") << endl;
    cout << "failure鐨勫崟鏁板舰寮忔槸锛? << make_plural(2, "failure") << endl;
    return 0;
}
#include <iostream>
#include <vector>
#include <string>
using namespace std;

void input_string(string &s)
{
    s.reserve(100);
    char c;
    while (cin >> c)
    {
        s.push_back(c);
    }
}

int main()
{
	string s;
	input_string(s);
	cout << s << endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <list>
#include <string>
#include <algorithm>
using namespace std;

inline void output_words(list<string> &words)
{
    for (auto iter = words.begin(); iter != words.end(); iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;
}

void elimDups(list<string> &words)
{
    output_words(words);

    words.sort();
    output_words(words);

    words.unique();
    output_words(words);
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    list<string> words;
    string word;
    while (in >> word)
    {
        words.push_back(word);
    }

    elimDups(words);
    return 0;
}
#include <string>
using std::string;

#include <fstream>
using std::ifstream;

#include <iostream>
using std::cin;
using std::cout;
using std::cerr;
using std::endl;

#include <cstdlib>  // for EXIT_FAILURE

#include "strvec_TextQuery.h"
#include "make_plural.h"

void runQueries(ifstream &infile)
{
	// infile is an ifstream that is the file we want to query
    TextQuery tq(infile);  // store the file and build the query map
    // iterate with the user: prompt for a word to find and print results
    while (true)
    {
        cout << "enter word to look for, or q to quit: ";
        string s;
        // stop if we hit end-of-file on the input or if a 'q' is entered
        if (!(cin >> s) || s == "q")
        {
            break;
        }
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
    if (argc < 2 || !(infile.open(argv[1]), infile))
    {
        cerr << "No input file!" << endl;
        return EXIT_FAILURE;
    }
	runQueries(infile);
    return 0;
}
#include <iostream>
#include "Sales_data.h"

int main()
{
    Sales_data book;
    std::cout << "请输入销售记录："<< std::endl;
    while (std::cin >> book)
    {
        std::cout << " ISBN、售出本数、原始价格、原始价格、实售价格、折扣为" << book << std::endl;
    }

    Sales_data trans1, trans2;
    std::cout << "请输入两条ISBN相同的销售记录：" << std::endl;
    std::cin.clear();  // 清空输入流的错误状态标志位，以便后面继续输入。
    std::cin >> trans1 >> trans2;
    if (compareIsbn(trans1, trans2))
    {
        std::cout << "汇总信息：ISBN、售出本数、原始价格、实售价格、折扣为 " << trans1 + trans2 << std::endl;
    }
    else
    {
        std::cout << "两条销售记录的ISBN不同" << std::endl;
    }

    Sales_data total, trans;
    std::cout << "请输入几条ISBN相同的销售记录：" << std::endl;
    std::cin.clear(); // 清空输入流的错误状态标志位，以便后面继续输入。
    if (std::cin >> total)
    {
        while (std::cin >> trans)
        {
            if (compareIsbn(total, trans)) // ISBN 相同
            {
                total = total + trans;
            }
            else // ISBN 不同
            {
                std::cout << "当前书籍ISBN不同" << std::endl;
                break;
            }
        }
        std::cout << "有效汇总信息：ISBN、售出本数、原始价格、实售价格、折扣为" << total << std::endl;
    }
    else
    {
        std::cout << "没有数据" << std::endl;
        return -1;
    }

    int num = 1;    //记录当前书籍的销售记录总数
    std::cout << "请输入若干销售记录："<< std::endl;
    std::cin.clear();  // 清空输入流的错误状态标志位，以便后面继续输入。
    if (std::cin >> trans1)
    {
        while (std::cin >> trans2)
        {
            if (compareIsbn(trans1, trans2)) // ISBN 相同
            {
                num++;
            }
            else // ISBN 不同
            {
                std::cout << trans1.isbn() << "共有" << num << "条销售记录" << std::endl;
                trans1 = trans2;
                num = 1;
            }
        }
        std::cout << trans1.isbn() << "共有" << num << "条销售记录" << std::endl;
    }
    else
    {
        std::cout << "没有数据" << std::endl;
        return -1;
    }

    return 0;
}
#include <iostream>
#include <string>
using namespace std;

//该类型没有显式定义默认构造函数，编译器也不会为它合成一个
class NoDefault
{
public:
    NoDefault(int i)
    {
        val = i;
    }
    int val;
};

class C
{
public:
    NoDefault nd;
    //必须显式调用Nodefault的带参构造函数初始化nd
    C(int i = 0) : nd(i) { }
};

int main()
{
    C c;    //使用了类型C的默认构造函数
    cout << c.nd.val << endl;
    return 0;
}
#include <iostream>
#include <vector>
#include <string>
using namespace std;

void replace_string(string &s, const string &oldVal, const string &newVal)
{
    auto l = oldVal.size();
    if (!l)       // 要查找的字符串为空
    {
        return;
    }

    auto iter = s.begin();
    while (iter <= s.end() - l) // 末尾少于oldVal长度的部分无需检查
    {
        auto iter1 = iter;
        auto iter2 = oldVal.begin();
        // s中iter开始的子串必须每个字符都与oldVal相同
        while (iter2 != oldVal.end() && *iter1 == *iter2)
        {
            iter1++;
            iter2++;
        }

        if (iter2 == oldVal.end())    // oldVal耗尽——字符串相等
        {
            iter = s.erase(iter, iter1);  // 删除s中与oldVal相等部分
            if (newVal.size())          // 替换子串是否为空
            {
                iter2 = newVal.end();       // 由后至前逐个插入newVal中字符
                do
                {
                    iter2--;
                    iter = s.insert(iter, *iter2);
                } while (iter2 > newVal.begin());
            }
            iter += newVal.size();        // 迭代器移动到新插入内容之后
        }
        else
        {
            iter++;
        }
    }
}
int main()
{
  	string s="tho thru tho!";
  	replace_string(s, "thru", "through");
  	cout << s << endl;

  	replace_string(s, "tho", "though");
  	cout << s << endl;

  	replace_string(s, "through", "");
  	cout << s << endl;

    return 0;
}
#include <iostream>
using namespace std;

int main()
{
    int ia[3][4] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
    cout << "利用范围for语句输出多维数组的内容：" << endl;
    for (int (&row)[4] : ia)
    {
        for (int &col : row)
        {
            cout << col << " ";
        }
        cout << endl;
    }

    cout << "利用普通for语句和下标运算符输出多维数组的内容：" << endl;
    for (int i = 0; i != 3; i++)
    {
        for (int j = 0; j != 4; j++)
        {
            cout << ia[i][j] << " ";
        }
        cout << endl;
    }

    cout << "利用普通for语句和指针输出多维数组的内容：" << endl;
    for (int (*p)[4] = ia; p != ia + 3; p++)
    {
        for (int *q = *p; q != *p + 4; q++)
        {
            cout << *q << " ";
        }
        cout << endl;
    }
    return 0;
}
#include <iostream>
#include <vector>
#include <string>
using namespace std;

void replace_string(string &s, const string &oldVal, const string &newVal)
{
    int p = 0;
    while ((p = s.find(oldVal, p)) != string::npos)   // 在s中查找oldVal
    {
        s.replace(p, oldVal.size(), newVal);  // 将找到的子串替换为newVal的内容
        p += newVal.size();   // 下标调整到新插入内容之后
    }
}

int main()
{
	string s="tho thru tho!";
	replace_string(s, "thru", "through");
	cout << s << endl;

	replace_string(s, "tho", "though");
	cout << s << endl;

	replace_string(s, "through", "");
	cout << s << endl;

    return 0;
}
#include <iostream>
#include <map>
#include <algorithm>
#include <functional>
using namespace std;

map<string, function<int (int, int)>> binOps =
{
	{"+", plus<int>()},
	{"-", minus<int>()},
	{"*", multiplies<int>()},
	{"/", divides<int>()},
	{"%", modulus<int>()}
};

int main()
{
	int left, right;
	string op;
	cin >> left >> op >> right;
	cout << binOps[op](left, right) << endl;
	return 0;
}
#include <iostream>
using namespace std;
using int_array = int[4];

int main()
{
    int ia[3][4] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
    cout << "利用范围for语句输出多维数组的内容：" << endl;
    for (int_array &row : ia)
    {
        for (int &col : row)
        {
            cout << col << " ";
        }
        cout << endl;
    }

    cout << "利用普通for语句和下标运算符输出多维数组的内容：" << endl;
    for (int i = 0; i != 3; i++)
    {
        for (int j = 0; j != 4; j++)
        {
            cout << ia[i][j] << " ";
        }
        cout << endl;
    }

    cout << "利用普通for语句和指针输出多维数组的内容：" << endl;
    for (int_array *p = ia; p != ia + 3; p++)
    {
        for (int *q = *p; q != *p + 4; q++)
        {
            cout << *q << " ";
        }
        cout << endl;
    }
    return 0;
}
#include <iostream>
#include <vector>
#include <string>
using namespace std;

void name_string(string &name, const string &prefix, const string &suffix)
{
    name.insert(name.begin(), 1, ' ');
    name.insert(name.begin(), prefix.begin(), prefix.end());  // 插入前缀
    name.append(" ");
    name.append(suffix.begin(), suffix.end());    // 插入后缀
}

int main()
{
  	string s="James Bond";
  	name_string(s, "Mr.", "II");
  	cout << s << endl;

    s = "M";
  	name_string(s, "Mrs.", "III");
  	cout << s << endl;

    return 0;
}
#include <iostream>
using namespace std;

int main()
{
    int ia[3][4] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
    cout << "利用范围for语句输出多维数组的内容：" << endl;
    for (auto &row : ia)
    {
        for (auto &col : row)
        {
            cout << col << " ";
        }
        cout << endl;
    }

    cout << "利用普通for语句和下标运算符输出多维数组的内容：" << endl;
    for (auto i = 0; i != 3; i++)
    {
        for (auto j = 0; j != 4; j++)
        {
            cout << ia[i][j] << " ";
        }
        cout << endl;
    }

    cout << "利用普通for语句和指针输出多维数组的内容：" << endl;
    for (auto p = ia; p != ia + 3; p++)
    {
        for (auto q = *p; q != *p + 4; q++)
        {
            cout << *q << " ";
        }
        cout << endl;
    }
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

void find_char(string &s, const string &chars)
{
    cout << "在" << s << "中查找" << chars << "中字符" << endl;
    string::size_type pos = 0;
    while ((pos = s.find_first_of(chars, pos)) != string::npos)  // 找到字符
    {
        cout << "pos: " << pos << ", char: " << s[pos] << endl;
        pos++;    // 移动到下一字符
    }
}

int main()
{
    string s="ab2c3d7R4E6";
    cout << "查找所有数字" << endl;
  	find_char(s, "0123456789");
  	cout << endl << "查找所有字母" << endl;
  	find_char(s, "abcdefghijklmnopqrstuvwxyz"\
                 "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
    return 0;
}
#include <iostream>
#include "String.h"
#include <vector>
using std::cout;
using std::endl;
using std::vector;

int main()
{
    String s1("One"), s2("Two");
    cout << s1 << " " << s2 << endl << endl;;
    String s3(s2);
    cout << s1 << " " << s2 << " " << s3 << endl << endl;
    s3 = s1;
    cout << s1 << " " << s2 << " " << s3 << endl << endl;
    s3 = String("Three");
    cout << s1 << " " << s2 << " " << s3 << endl << endl;

    vector<String> vs;
    //vs.reserve(4);
    vs.push_back(s1);
    vs.push_back(std::move(s2));
    vs.push_back(String("Three"));
    vs.push_back("Four");
    for_each(vs.begin(), vs.end(), [](const String &s){ cout << s << " "; });
    cout << endl;

  	return 0;
}
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
#include <iostream>
#include <vector>
using namespace std;

//閫掑綊鍑芥暟杈撳嚭vector<int>鐨勫唴瀹?
void print(vector<int> vInt, unsigned index)
{
    unsigned sz = vInt.size();
	//璁剧疆鍦ㄦ澶勮緭鍑鸿皟璇曚俊鎭?
    #ifndef NDEBUG
    cout << "vector瀵硅薄鐨勫ぇ灏忔槸锛? << sz << endl;
    #endif // NDEBUG
    if (!vInt.empty() && index < sz)
    {
        cout << vInt[index] << endl;
        print(vInt, index + 1);
    }
}

int main()
{
    vector<int> v = {1, 3, 5, 7, 9, 11, 13, 15};
    print(v, 0);
    return 0;
}
#include <iostream>
#include <typeinfo>
using std::cout; using std::endl;

template <typename T> void f(T a)
{
    cout << "f(T), T是" << typeid(T).name() << endl;
}

template <typename T> void f(const T *a)
{
    cout << "f(const T*), const T*是" << typeid(const T*).name() << endl;
}

template <typename T> void g(T a)
{
    cout << "g(T), T是" << typeid(T).name() << endl;
}

template <typename T> void g(T *a)
{
    cout << "g(T*), T*是" << typeid(T*).name() << endl;
}

int main()
{
    int i = 42, *p = &i;
    const int ci = 0, *p2 = &ci;
    g(42); g(p); g(ci); g(p2);
    f(42); f(p); f(ci); f(p2);
	return 0;
}
#include <iostream>
#include <fstream>
#include <string>
using namespace std;

void find_longest_word(ifstream &in)
{
    string s, longest_word;
    int max_length = 0;

    while (in >> s)
    {
        if (s.find_first_of("bdfghjklpqty") != string::npos)
        {
            continue;     // 包含上出头或下出头字母
        }

        cout << s << " ";
        if (max_length < s.size())  // 新单词更长
        {
            max_length = s.size();  // 记录长度和单词
            longest_word = s;
        }
    }
    cout << endl << "最长字符串：" << longest_word << endl;
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);          // 打开文件
    if (!in)
    {
        cerr << "无法打开输入文件" << endl;
        return -1;
    }

    find_longest_word(in);
    return 0;
}
#include <iostream>
#include <string>

using namespace std;

int main()
{
    string s1, s2;
    cout << "请输入两个字符串：" << endl;
    cin >> s1 >> s2;
    if (s1 == s2)
    {
        cout << "两个字符串相等" << endl;
    }
    else if (s1 > s2)
    {
        cout << s1 << " 大于 " << s2 <<endl;
    }
    else
    {
        cout << s2 << " 大于 " << s1 <<endl;
    }
    return 0;
}
#include <iostream>
#include <string>

using namespace std;

int main()
{
    string s1, s2;
    cout << "请输入两个字符串：" << endl;
    cin >> s1 >> s2;
    auto len1 = s1.size();
    auto len2 = s2.size();
    if (len1 == len2)
    {
        cout << s1 << " 和 " << s2 << " 的长度都是 " << len1 << endl;
    }
    else if (len1 > len2)
    {
        cout << s1 << " 比 " << s2 << " 的长度多 " << len1 - len2 << endl;
    }
    else
    {
        cout << s1 << " 比 " << s2 << " 的长度小 " << len2 - len1 << endl;
    }
    return 0;
}
#include <iostream>
using namespace std;

int main()
{
    int grade;
    cout << "请输入您的成绩：";
    cin >> grade;
    if (grade < 0 || grade > 100)
    {
        cout << "该成绩不合法" << endl;
        return -1;
    }
    if (grade == 100)    //处理满分的情况
    {
        cout << "等级成绩是：" << "A++" << endl;
        return -1;
    }
    if (grade < 60)      //处理不及格的情况
    {
        cout << "等级成绩是：" << "F" << endl;
        return -1;
    }

    int iU = grade / 10;    //成绩的十位数
    int iT = grade % 10;    //成绩的个位数
    string score, level, lettergrade;
    //根据成绩的十位数字确定score
    if (iU == 9)
    {
        score = "A";
    }
    else if (iU == 8)
    {
        score = "B";
    }
    else if (iU == 7)
    {
        score = "C";
    }
    else
    {
        score = "D";
    }

    //根据成绩的个位数字确定level
    if (iT < 3)
    {
        level = "-";
    }
    else if (iT > 7)
    {
        level = "+";
    }
    else
    {
        level = "";
    }

    //累加求得等级成绩
    lettergrade = score + level;
    cout << "等级成绩是：" << lettergrade << endl;

    return 0;
}
#include <iostream>
#include <cmath>
using namespace std;

//第一个函数通过if-else语句计算绝对值
double myABS(double val)
{
    if (val < 0)
    {
        return val * -1;
    }
    else
    {
        return val;
    }
}

//第二个函数调用cmath头文件的abs函数计算绝对值
double myABS2(double val)
{
    return abs(val);
}

int main()
{
    double num;
    cout << "请输入一个数：";
    cin >> num;
    cout << num << "的绝对值是：" << myABS(num) << endl;
    cout << num << "的绝对值是：" << myABS2(num) << endl;
    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

vector<int>::iterator search_vec(vector<int>::iterator beg, vector<int>::iterator end, int val)
{
    for (; beg != end; beg++)     // 遍历范围
    {
        if (*beg == val)          // 检查是否与给定值相等
        {
            return beg;             // 搜索成功，返回元素对应迭代器
        }
    }
    return end;                 // 搜索失败，返回尾后迭代器
}

int main()
{
  vector<int> ilist = {1, 2, 3, 4, 5, 6, 7};
  cout << search_vec(ilist.begin(), ilist.end(), 3) - ilist.begin() << endl;
  cout << search_vec(ilist.begin(), ilist.end(), 8) - ilist.begin() << endl;

  return 0;
}
#include <iostream>
#include <algorithm>
#include <string.h>
using namespace std;

int main(int argc, char *argv[])
{
    char *p[] = { "Hello", "World", "!" };
    char *q[] = { strdup(p[0]), strdup(p[1]), strdup(p[2])};
    char *r[] = { p[0], p[1], p[2] };

    cout << equal(begin(p), end(p), q) << endl;
    cout << equal(begin(p), end(p), r) << endl;
    return 0;
}
#include <iostream>
#include <string>

using namespace std;

template <typename T, size_t N>
void print(const T (&a)[N])
{
    for (auto iter = begin(a); iter != end(a); iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;
}

int main()
{
    int a[6] = { 0, 2, 4, 6, 8, 10 };
    string vs[3] = { "Hello", "World", "!" };

    print(a);
    print(vs);

    return 0;
}

#include <cassert>
#include <utility>
using std::pair;

#include <string>
using std::string;

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
typedef pair<vector<Sales_data>::size_type,
              pair<vector<Sales_data>::const_iterator,
              vector<Sales_data>::const_iterator>> matches;

// files holds the transactions for every store
// findBook returns a vector with an entry for each store that sold the given book
vector<matches>
findBook(const vector<vector<Sales_data>> &files, const string &book)
{
	vector<matches> ret;  // initially empty
	// for each store find the range of matching books, if any
	for (auto it = files.cbegin(); it != files.cend(); ++it)
	{
		// find the range of Sales_data that have the same ISBN
		auto found = equal_range(it->cbegin(), it->cend(), book, compareIsbn);
		if (found.first != found.second)  // this store had sales
		{
			// remember the index of this store and the matching range
			ret.push_back(make_pair(it - files.cbegin(), found));
		}
	}
	return ret; // empty if no matches found
}

vector<Sales_data> build_store(const string &s)
{
	Sales_data item;
	vector<Sales_data> ret;
	ifstream is(s);
	while (read(is, item))
	{
		ret.push_back(item);
	}
	sort (ret.begin(), ret.end(), lt);  // need sort for equal_range to work
	return ret;
}

void reportResults(istream &in, ostream &os, const vector<vector<Sales_data>> &files)
{
	string s;   // book to look for
	while (in >> s)
	{
		auto trans = findBook(files, s);  // stores that sold this book
		if (trans.empty())
		{
			cout << s << " not found in any stores" << endl;
			continue;  // get the next book to look for
		}
		for (const auto &store : trans)   // for every store with a sale
		{
			// get<n> returns the specified member from the tuple in store
			os << "store " << store.first << " sales: "
			   << accumulate(store.second.first, store.second.second, Sales_data(s))
			   << endl;
		}
	}
}

int main(int argc, char **argv)
{
	assert(argc > 1);
	// each element in files holds the transactions for a particular store
	vector<vector<Sales_data>> files;
	for (int cnt = 1; cnt != argc; ++cnt)
	{
		files.push_back(build_store(argv[cnt]));
	}

	ifstream in("findbook.in");  // ISBNs to search for
	reportResults(in, cout, files);
}
#include <iostream>

int main()
{
    std::cout << "请输入两个数";
    std::cout << std::endl;
    int v1, v2;
    std::cin >> v1 >> v2;
    std::cout << v1 << "和" << v2 << "的积为" << v1 * v2 << std::endl;
    return 0;
}
#include <iostream>
#include <string>
#include <vector>
using namespace std;

int main()
{
	vector<string> vs = {"12.3", "-4.56", "+7.8e-2"};
	float sum = 0;

    for (auto iter = vs.begin(); iter != vs.end(); iter++)
    {
        sum += stof(*iter);
    }

    cout << "和：" << sum << endl;
    return 0;
}
#include <iostream>
#include <string>
#include <vector>
using namespace std;

int main()
{
	vector<string> vs = {"123", "+456", "-789"};
	int sum = 0;

    for (auto iter = vs.begin(); iter != vs.end(); iter++)
    {
        sum += stoi(*iter);
    }

    cout << "和：" << sum << endl;
    return 0;
}
#include <iostream>
#include <string>
#include "date.h"
using namespace std;

int main()
{
    string dates[] = {"Jan 1,2014", "February 1 2014", "3/1/2014",
                      //"Jcn 1,2014",
                      //"Janvary 1,2014",
                      //"Jan 32,2014",
                      //"Jan 1/2014",
                      "3 1 2014 ",
                      };
    try
    {
        for (auto ds : dates)
        {
            date d1(ds);
            cout << d1;
        }
    }
    catch (invalid_argument e)
    {
        cout << e.what() << endl;
    }

    return 0;
}
#include <iostream>
#include <string>
using std::cout;
using std::endl;
using std::string;

template <typename T, typename... Args>
void foo(const T &t, const Args& ... rest)
{
    cout << sizeof...(Args) << " "; // 模板类型参数的数目
    cout << sizeof...(rest) << endl; // 函数参数的数目
}

int main()
{
    int i = 0; double d = 3.14; string s = "how now brown cow";
    foo(i, s, 42, d); 	// 包中有三个参数
    foo(s, 42, "hi"); 	// 包中有两个参数
    foo(d, s); 			// 包中有一个参数
    foo("hi"); 			// 空包

    return 0;
}
#include <iostream>
using namespace std;

void f()
{
    cout << "璇ュ嚱鏁版棤闇€鍙傛暟" << endl;
}

void f(int)
{
    cout << "璇ュ嚱鏁版湁涓€涓暣鍨嬪弬鏁? << endl;
}

void f(int, int)
{
    cout << "璇ュ嚱鏁版湁涓や釜鏁村瀷鍙傛暟" << endl;
}

void f(double a, double b = 3.14)
{
    cout << "璇ュ嚱鏁版湁涓や釜鍙岀簿搴︽诞鐐瑰瀷鍙傛暟" << endl;
}

int main()
{
    f(2.56, 42); // error: call of overloaded 'f(double, int)' is ambiguous.
    f(42);
    f(42, 0);
    f(2.56, 3.14);
    return 0;
}
#include <iostream>
#include <string>
#include <deque>
#include <stack>
#include <stdexcept>
using namespace std;

// 表示栈中对象的不同类型
enum obj_type {LP, RP, ADD, SUB, VAL};
struct obj
{
    obj(obj_type type, double val = 0) { t = type; v = val; }
    obj_type t;
    double v;
};

inline void skipws(string &exp, size_t &p)
{
    p = exp.find_first_not_of(" ", p);
}

inline void new_val(stack<obj> &so, double v)
{
    if (so.empty() || so.top().t == LP)  // 空栈或左括号
    {
        so.push(obj(VAL, v));
        //cout << "push " << v << endl;
    }
    else if (so.top().t == ADD || so.top().t == SUB)
    {
        // 之前是运算符
        obj_type type = so.top().t;
        so.pop();
        /*if (type == ADD)
          cout << "pop +" << endl;
        else cout << "pop -" << endl;*/
        //cout << "pop " << so.top().v << endl;
        // 执行加减法
        if (type == ADD)
        {
            v += so.top().v;
        }
        else
        {
            v = so.top().v - v;
        }
        so.pop();
        so.push(obj(VAL, v));   // 运算结果压栈
        //cout << "push " << v << endl;
    } else throw invalid_argument("缺少运算符");
}

int main()
{
    stack<obj> so;
    string exp;
    size_t p = 0, q;
    double v;

    cout << "请输入表达式：";
    getline(cin, exp);

    while (p < exp.size())
    {
        skipws(exp, p);     // 跳过空格
        if (exp[p] == '(')  // 左括号直接压栈
        {
            so.push(obj(LP));
            p++;
            //cout << "push LP" << endl;
        }
        else if (exp[p] == '+' || exp[p] == '-')
        {
            // 新运算符
            if (so.empty() || so.top().t != VAL)
            {
                // 空栈或之前不是运算数
                throw invalid_argument("缺少运算数");
            }

            if (exp[p] == '+')    // 运算符压栈
            {
                so.push(obj(ADD));
            }
            else
            {
                so.push(obj(SUB));
            }
            p++;
            //cout << "push " << exp[p - 1] << endl;
        }
        else if (exp[p] == ')') //右括号
        {
            p++;

            if (so.empty())   // 之前无配对儿左括号
            {
                throw invalid_argument("未匹配右括号");
            }

            if (so.top().t == LP)   // 一对儿括号之间无内容
            {
                throw invalid_argument("空括号");
            }

            if (so.top().t == VAL)  // 正确：括号内运算结果
            {
                v = so.top().v;
                so.pop();
                //cout << "pop " << v << endl;

                if (so.empty() || so.top().t != LP)
                {
                    throw invalid_argument("未匹配右括号");
                }

                so.pop();
                //cout << "pop LP" << endl;
                new_val(so, v);   // 与新运算数逻辑一致
            }
            else  // 栈顶必定是运算符
            {
                throw invalid_argument("缺少运算数");
            }
        }
        else  // 应该是运算数
        {
            v = stod(exp.substr(p), &q);
            p += q;
            new_val(so, v);
        }
    }

    if (so.size() != 1 || so.top().t != VAL)
    {
        throw invalid_argument("非法表达式");
    }
    cout << so.top().v << endl;
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

// 用来终止递归并打印最后一个元素的函数
// 此函数必须在可变参数版本的print定义之前声明
template<typename T>
ostream &print(ostream &os, const T &t)
{
    return os << t << endl; // 包中最后一个元素之后不打印分隔符
}

// 包中除了最后一个元素之外的其他元素都会调用这个版本的print
template <typename T, typename... Args>
ostream &print(ostream &os, const T &t, const Args&... rest)//扩展Args
{
    os << t << ", ";            // 打印第一个实参
    return print(os, rest...);  // 扩展rest，递归打印其他参数
}

int main()
{
    int i = 0;
    string s = "Hello";

    print(cout, i);
    print(cout, i, s);
    print(cout, i, s, 42.1, 'A', "End");
	return 0;
}

#include <iostream>
#include <string>
using namespace std;

class HasPtr
{
public:
    HasPtr(const string &s = string()) : ps(new string(s)), i(0) {}
    HasPtr(const HasPtr &p) : ps(new string(*p.ps)), i(p.i)   // 拷贝构造函数
    {
        cout << "Copy Constructor" << endl;
    }
    HasPtr(HasPtr &&p) noexcept : ps(p.ps), i(p.i) // 移动构造函数
    {
        p.ps = 0; cout << "Move Constructor" << endl;
    }
    HasPtr& operator=(const HasPtr&);  // 拷贝赋值运算符
    HasPtr& operator=(HasPtr&&) noexcept;  // 移动赋值运算符
    HasPtr& operator=(const string&);  // 赋予新string
    string& operator*();       // 解引用
    ~HasPtr();
private:
    string *ps;
    int i;
};

HasPtr::~HasPtr()
{
    delete ps; 		// 释放string内存
}

inline HasPtr& HasPtr::operator=(const HasPtr &rhs)
{
    cout << "Copy Assignment" << endl;
    auto newps = new string(*rhs.ps); // 拷贝指针指向的对象
    delete ps;					// 销毁原string
    ps = newps;					// 指向新string
    i = rhs.i; 					// 使用内置的int赋值
    return *this; 				// 返回一个此对象的引用
}

inline HasPtr& HasPtr::operator=(HasPtr &&rhs) noexcept
{
    cout << "Move Assignment" << endl;
    if (this != &rhs)
    {
        delete ps;      // 释放旧string
        ps = rhs.ps;		// 从rhs接管string
        rhs.ps = nullptr;		// 将rhs置于析构安全状态
        rhs.i = 0;
    }
    return *this; 				// 返回一个此对象的引用
}

HasPtr& HasPtr::operator=(const string &rhs)
{
    *ps = rhs;
    return *this;
}

string& HasPtr::operator*()
{
    return *ps;
}

int main(int argc, char **argv)
{
    HasPtr h("hi mom!");
    {
        HasPtr h2(h);  // 拷贝构造函数
        HasPtr h3(std::move(h2));  // 移动构造函数
    }

    {
        HasPtr h2, h3;
        h2 = h;  // 拷贝赋值运算符
        h3 = std::move(h2);  // 移动赋值运算符
    }

    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

//鍔犳硶
int func1(int a, int b)
{
    return a + b;
}

//鍑忔硶
int func2(int a, int b)
{
    return a - b;
}

//涔樻硶
int func3(int a, int b)
{
    return a * b;
}

//闄ゆ硶
int func4(int a, int b)
{
    return a / b;
}

int main()
{
    decltype(func1) *p1 = func1, *p2 = func2, *p3 = func3, *p4 = func4;
    vector<decltype(func1)*> vF = {p1, p2, p3, p4};
    return 0;
}
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

#include <iostream>
#include <vector>
using namespace std;

//鍔犳硶
int func1(int a, int b)
{
    return a + b;
}

//鍑忔硶
int func2(int a, int b)
{
    return a - b;
}

//涔樻硶
int func3(int a, int b)
{
    return a * b;
}

//闄ゆ硶
int func4(int a, int b)
{
    return a / b;
}

void Compute(int a, int b, int (*p)(int, int))
{
    cout << p(a,b) << endl;
}

int main()
{
    int i = 5, j = 10;
    decltype(func1) *p1 = func1, *p2 = func2, *p3 = func3, *p4 = func4;
    vector<decltype(func1)*> vF = {p1, p2, p3, p4};
    for (auto p : vF)	//閬嶅巻vector涓殑姣忎釜鍏冪礌锛屼緷娆¤皟鐢ㄥ洓鍒欒繍绠楀嚱鏁?
    {
        Compute(i, j, p);
    }
    return 0;
}
#include "Vec.h"

#include <string>
using std::string;

#include <iostream>
using std::cin; using std::cout; using std::endl;
using std::istream;

void print(const Vec<string> &svec)
{
	for (auto it : svec)
	{
		cout << it << " " ;
	}
	cout <<endl;
}

Vec<string> getVec(istream &is)
{
	Vec<string> svec;
	string s;
	while (is >> s)
	{
		svec.push_back(s);
	}
	return svec;
}

int main()
{
	Vec<string> svec = getVec(cin);
	print(svec);

	cout << "emplace " << svec.size() << endl;
	svec.emplace_back("End");
	svec.emplace_back(3, '!');
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
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

class Foo
{
public:
    Foo sorted() &&; 		// 可用于可改变的右值
    Foo sorted() const &; 	// 可用于任何类型的Foo
    // Foo的其他成员的定义
private:
    vector<int> data;
};

// 本对象为右值，因此可以原址排序
Foo Foo::sorted() &&
{
    cout << "右值引用版本" << endl;
    sort(data.begin(), data.end());
    return *this;
}

// 本对象是const或是一个左值，哪种情况我们都不能对其进行原址排序
Foo Foo::sorted() const &
{
    cout << "左值引用版本" << endl;
    Foo ret(*this); 							// 拷贝一个副本
    return ret.sorted();
    // return Foo(*this).sorted();
}

int main(int argc, char **argv)
{
    Foo f;
    f.sorted();
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    char cont = 'y';
    string s, result;
    cout << "请输入第一个字符串：" << endl;
    while (cin >> s)
    {
        result += s;
        cout << "是否继续（y or n）？" << endl;
        cin >> cont;
        if (cont == 'y' || cont == 'Y')
        {
            cout << "请输入下一个字符串：" << endl;
        }
        else
        {
            break;
        }
    }
    cout << "拼接后的字符串是：" << result <<endl;
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    char cont = 'y';
    string s, result;
    cout << "请输入第一个字符串：" << endl;
    while (cin >> s)
    {
        if (!result.size())	//第一个拼接的字符串之前不加空格
        {
            result += s;
        }
        else				//之后拼接的每个字符串之前加一个空格
        {
            result = result + " " + s;
        }
        cout << "是否继续（y or n）？" << endl;
        cin >> cont;
        if (cont == 'y' || cont == 'Y')
        {
            cout << "请输入下一个字符串：" << endl;
        }
        else
        {
            break;
        }
    }
    cout << "拼接后的字符串是：" << result <<endl;
    return 0;
}
#include <iostream>
using namespace std;

int main()
{
    int grade;
    cout << "请输入您的成绩：";
    cin >> grade;
    if (grade < 0 || grade > 100)
    {
        cout << "该成绩不合法" << endl;
        return -1;
    }
    if (grade == 100)    //处理满分的情况
    {
        cout << "等级成绩是：" << "A++" << endl;
        return -1;
    }
    if (grade < 60)      //处理不及格的情况
    {
        cout << "等级成绩是：" << "F" << endl;
        return -1;
    }

    int iU = grade / 10;    //成绩的十位数
    int iT = grade % 10;    //成绩的个位数
    string score, level, lettergrade;
    //根据成绩的十位数字确定score
    score = (iU == 9) ? "A"
                      : (iU == 8) ? "B"
                                  : (iU == 7) ? "C" : "D";
    //根据成绩的个位数字确定level
    level = (iT < 3) ? "-"
                     : (iT > 7) ? "+" : "";
    //累加求得等级成绩
    lettergrade = score + level;
    cout << "等级成绩是：" << lettergrade << endl;

    return 0;
}
#include <iostream>
using namespace std;

//该函数同时使用了形参、普通局部变量和静态局部变量
double myADD(double val1, double val2)  //val1和val2是形参
{
    double result = val1 + val2;    //result是普通局部变量
    static unsigned iCnt = 0;       //iCnt是静态局部变量
    ++iCnt;
    cout << "该函数已经累计执行了" << iCnt << "次" << endl;
    return result;
}

int main()
{
    double num1, num2;
    cout << "请输入两个数：";
    while (cin >> num1 >> num2)
    {
        cout << num1 << "与" << num2 << "的求和结果是：" << myADD(num1, num2) << endl;
    }
    return 0;
}
#include <iostream>
#include <fstream>
#include "Sales_data.h"
using namespace std;

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        cerr << "请给出文件名" << endl;
        return -1;
    }

    ifstream in(argv[1]);
    if (!in)
    {
        cerr << "无法打开输入文件" << endl;
        return -1;
    }

    Sales_data total;  // 保存当前求和结果的变量
    if (read(in, total))  // 读入第一笔交易
    {
        Sales_data trans; 	// 保存下一条交易数据的变量
        while(read(in, trans))  // 读入剩余的交易
        {
            if (total.isbn() == trans.isbn()) 	// 检查isbn
            {
                total.combine(trans);	 // 更新变量total当前的值
            }
            else
            {
                print(cout, total) << endl; 	// 输出结果
                total = trans;  // 处理下一本书
            }
        }
        print(cout, total) << endl; 	// 输出最后一条交易
    }
    else
    { 									      // 没有输入任何信息
        cerr << "没有数据" << endl; 	// 通知用户
    }

    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<int> vi;
    int val;
    while (in >> val)
    {
        vi.push_back(val);
        cout << val << " ";
    }
    cout << endl;

    fill_n(vi.begin(), vi.size(), 0);
    for (auto iter = vi.begin(); iter != vi.end(); iter++)
    {
        cout << *iter << " ";
    }
    return 0;
}
#include <iostream>
#include <vector>
using namespace std;

vector<int> *new_vector(void)
{
    return new (nothrow) vector<int>;
}

void read_ints(vector<int> *pv)
{
    int v;
    while (cin >> v)
    {
        pv->push_back(v);
    }
}

void print_ints(vector<int> *pv)
{
    for (const auto &v : *pv)
    {
        cout << v << " ";
    }
    cout << endl;
}

int main(int argc, char **argv)
{
    vector<int> *pv = new_vector();
    if (!pv)
    {
        cout << "内存不足！" << endl;
        return -1;
    }

    read_ints(pv);
    print_ints(pv);
    delete pv;
    pv = nullptr;
  	return 0;
}
#include <iostream>
#include <string>

using namespace std;

template <typename T, size_t N>
const T* my_begin(const T (&a)[N])
{
    return &a[0];
}

template <typename T, size_t N>
const T* my_end(const T (&a)[N])
{
    return &a[0] + N;
}

template <typename T, size_t N>
void print(const T (&a)[N])
{
    for (auto iter = my_begin(a); iter != my_end(a); iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;
}

int main()
{
    int a[6] = { 0, 2, 4, 6, 8, 10 };
    string vs[3] = { "Hello", "World", "!" };

    print(a);
    print(vs);

    return 0;
}

#include <cassert>
#include <utility>
using std::pair;

#include <string>
using std::string;

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
class matches
{
public:
    matches(vector<Sales_data>::size_type n,
            pair<vector<Sales_data>::const_iterator,
            vector<Sales_data>::const_iterator> f) : num(n), first(f.first), last(f.second) {}
    vector<Sales_data>::size_type get_num() const { return num; }
    vector<Sales_data>::const_iterator get_first() const { return first; }
    vector<Sales_data>::const_iterator get_last() const { return last; }
private:
    vector<Sales_data>::size_type num;
    vector<Sales_data>::const_iterator first, last;
};


// files holds the transactions for every store
// findBook returns a vector with an entry for each store that sold the given book
vector<matches>
findBook(const vector<vector<Sales_data>> &files,
         const string &book)
{
	vector<matches> ret;  // initially empty
	// for each store find the range of matching books, if any
	for (auto it = files.cbegin(); it != files.cend(); ++it)
    {
		// find the range of Sales_data that have the same ISBN
		auto found = equal_range(it->cbegin(), it->cend(), book, compareIsbn);
		if (found.first != found.second)  // this store had sales
        {
			// remember the index of this store and the matching range
			ret.push_back(matches(it - files.cbegin(), found));
        }
	}
	return ret; // empty if no matches found
}

vector<Sales_data> build_store(const string &s)
{
	Sales_data item;
	vector<Sales_data> ret;
	ifstream is(s);
	while (read(is, item))
    {
		ret.push_back(item);
    }
	sort (ret.begin(), ret.end(), lt);  // need sort for equal_range to work
	return ret;
}

void reportResults(istream &in, ostream &os, const vector<vector<Sales_data>> &files)
{
	string s;   // book to look for
	while (in >> s)
    {
		auto trans = findBook(files, s);  // stores that sold this book
		if (trans.empty())
        {
			cout << s << " not found in any stores" << endl;
			continue;  // get the next book to look for
		}
		for (const auto &store : trans)   // for every store with a sale
        {
			// get<n> returns the specified member from the tuple in store
			os << "store " << store.get_num() << " sales: "
			   << accumulate(store.get_first(), store.get_last(), Sales_data(s))
			   << endl;
        }
	}
}

int main(int argc, char **argv)
{
	assert(argc > 1);
	// each element in files holds the transactions for a particular store
	vector<vector<Sales_data>> files;
	for (int cnt = 1; cnt != argc; ++cnt)
    {
		files.push_back(build_store(argv[cnt]));
    }

	ifstream in("findbook.in");  // ISBNs to search for
	reportResults(in, cout, files);
}
#include <iostream>
using namespace std;

class Query_base
{
public:
    Query_base() {}
    virtual ~Query_base() {}
    // ...
};

class BinaryQuery : public Query_base
{
public:
    BinaryQuery() {}
    virtual ~BinaryQuery() {}
    // ...
};

class AndQuery : public BinaryQuery
{
public:
    AndQuery() {}
    virtual ~AndQuery() {}
    // ...
};

int main()
{
    Query_base *qb = new Query_base;
    if (dynamic_cast<AndQuery*>(qb) != NULL)
    {
        cout << "success." << endl;
    }
    else
    {
        cout << "failure." << endl;
    }

    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    string s;
    cout << "请输入一个字符串，可以包含空格：" << endl;
    getline(cin, s);		//读取整行，遇回车符结束
    for (auto &c : s)	//依次处理字符串中的每一个字符
    {
        c = 'X';
    }
    cout << s <<endl;
    return 0;
}
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
	while (cin >> item)
	{
		SDset.insert(item);
	}
	cout << SDset.size() << endl;
	for (auto sd : SDset)
	{
    	cout << sd << endl;
    }

	return 0;
}
#include <iostream>
#include <vector>
#include <cstring>

using namespace std;

template <typename T>
int occur(vector<T> &vec, const T &v)
{
    int ret = 0;

    for (auto a : vec)
    {
        if (a == v)
        {
            ret++;
        }
    }
    return ret;
}

template <>
int occur(vector<char *> &vec, char * const &v)
{
    int ret = 0;

    for (auto a : vec)
    {
        if (!strcmp(a, v))
        {
            ret++;
        }
    }
    return ret;
}

int main()
{
    vector<double> vd = { 1.1, 3.14, 2.2, 3.14, 3.3, 4.4};
    cout << occur(vd, 3.14) << endl;

    vector<int> vi = { 0, 1, 2, 3, 4, 5 };
    cout << occur(vi, 0) << endl;

    vector<string> vs = { "Hello", "World", "!" };
    cout << occur(vs, string("end")) << endl;

    vector<char *> vp;
    vp.push_back(new char[6]);
    vp.push_back(new char[6]);
    vp.push_back(new char[2]);
    strcpy(vp[0], "Hello");
    strcpy(vp[1], "World");
    strcpy(vp[2], "!");
    char *w = new char[6];
    strcpy(w, "World");
    cout << occur(vp, w) << endl;
    delete w;
    delete vp[2];
    delete vp[1];
    delete vp[0];

    return 0;
}
#include <iostream>
using namespace std;

//该函数仅用于统计执行的次数
unsigned myCnt()  //完成该函数的任务不需要任何参数
{
    static unsigned iCnt = -1;       //iCnt是静态局部变量
    ++iCnt;
    return iCnt;
}

int main()
{
    cout << "请输入任意字符后按回车键继续" << endl;
    char ch;
    while (cin >> ch)
    {
        cout << "函数myCnt()的执行次数是：" << myCnt() << endl;
    }
    return 0;
}
#include <iostream>
#include "Sales_data.h"
using namespace std;

int main()
{
    cout << "璇疯緭鍏ヤ氦鏄撹褰曪紙ISBN銆侀攢鍞噺銆佸師浠枫€佸疄闄呭敭浠凤級锛? << endl;
    Sales_data total; //淇濆瓨涓嬩竴鏉′氦鏄撹褰曠殑鍙橀噺
    // 璇诲叆绗竴鏉′氦鏄撹褰曪紝骞剁‘淇濇湁鏁版嵁鍙互澶勭悊
    if (read(cin, total))
    {
        Sales_data trans; //淇濆瓨鍜岀殑鍙橀噺
        //璇诲叆骞跺鐞嗗墿浣欎氦鏄撹褰?
        while (read(cin, trans))
        {
            //濡傛灉鎴戜滑浠嶅湪澶勭悊鐩稿悓鐨勪功
            if (total.isbn() == trans.isbn())
            {
                total = add(total, trans); //鏇存柊鎬婚攢鍞
            }
            else
            {
                //鎵撳嵃鍓嶄竴鏈功鐨勭粨鏋?
                print(cout, total);
                cout << endl;
                total = trans; //total鐜板湪琛ㄧず涓嬩竴鏈功鐨勯攢鍞
            }
        }
        print(cout, total);
        cout << endl; //鎵撳嵃鏈€鍚庝竴鏈功鐨勭粨鏋?
    }
    else
    {
        //娌℃湁杈撳叆锛佽鍛婅鑰?
        cerr << "No data?!" << endl;
        return -1; //琛ㄧず澶辫触
    }
    return 0;
}
#include <iostream>
#include <fstream>
#include "Sales_data.h"
using namespace std;

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        cerr << "请给出输入、输出文件名" << endl;
        return -1;
    }

    ifstream in(argv[1]);
    if (!in)
    {
        cerr << "无法打开输入文件" << endl;
        return -1;
    }

    ofstream out(argv[2]);
    if (!out)
    {
        cerr << "无法打开输出文件" << endl;
        return -1;
    }

    Sales_data total;  // 保存当前求和结果的变量
    if (read(in, total))  // 读入第一笔交易
    {
        Sales_data trans;  // 保存下一条交易数据的变量
        while (read(in, trans))  // 读入剩余的交易
        {
            if (total.isbn() == trans.isbn())  // 检查isbn
                total.combine(trans);  // 更新变量total当前的值
            else
            {
                print(out, total) << endl; 	// 输出结果
                total = trans;  // 处理下一本书
            }
        }
        print(out, total) << endl; 	// 输出最后一条交易
    }
    else  // 没有输入任何信息
    {
        cerr << "没有数据" << endl;  // 通知用户
    }

    return 0;
}
#include <iostream>
#include <map>
#include <string>
#include <algorithm>
using namespace std;

void add_family(map<string, vector<string>> &families, const string &family)
{
    if (families.find(family) == families.end())
    {
        families[family] = vector<string>();
    }
}

void add_child(map<string, vector<string>> &families, const string &family, const string &child)
{
    families[family].push_back(child);
}

int main(int argc, char *argv[])
{
    map<string, vector<string>> families;

    add_family(families, "张");
    add_child(families, "张", "强");
    add_child(families, "张", "刚");
    add_child(families, "王", "五");
    add_family(families, "王");

    for (auto f : families)
    {
        cout << f.first << "家的孩子：";
        for (auto c : f.second)
        {
            cout << c << " ";
        }
        cout << endl;
    }

    return 0;
}
#include <iostream>
#include <vector>
#include <memory>
using namespace std;

shared_ptr<vector<int>> new_vector(void)
{
    return make_shared<vector<int>>();
}

void read_ints(shared_ptr<vector<int>> spv)
{
    int v;
    while (cin >> v)
    {
        spv->push_back(v);
    }
}

void print_ints(shared_ptr<vector<int>> spv)
{
    for (const auto &v : *spv)
    {
        cout << v << " ";
    }
    cout << endl;
}

int main(int argc, char **argv)
{
    auto spv = new_vector();
    read_ints(spv);
    print_ints(spv);
  	return 0;
}
#include <iostream>
#include <string>

using namespace std;

template <typename T, size_t N>
constexpr int arr_size(const T (&a)[N])
{
    return N;
}

template <typename T, size_t N>
void print(const T (&a)[N])
{
    for (int i = 0; i < arr_size(a); i++)
    {
        cout << a[i] << " ";
    }
    cout << endl;
}

int main()
{
    int a[6] = { 0, 2, 4, 6, 8, 10 };
    string vs[3] = { "Hello", "World", "!" };

    print(a);
    print(vs);

    return 0;
}

#include <iostream>
#include <typeinfo>
using namespace std;

class Query_base
{
public:
    Query_base() {}
    virtual ~Query_base() {}
    // ...
};

class BinaryQuery : public Query_base
{
public:
    BinaryQuery() {}
    virtual ~BinaryQuery() {}
    // ...
};

class AndQuery : public BinaryQuery
{
public:
    AndQuery() {}
    virtual ~AndQuery() {}
    // ...
};

int main()
{
    Query_base *qb = new Query_base;
    try
    {
        dynamic_cast<AndQuery&>(*qb);
        cout << "success" << endl;
    }
    catch (bad_cast &bc)
    {
        cout << "failure" << endl;
    }

    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    string s;
    cout << "请输入一个字符串，可以包含空格：" << endl;
    getline(cin, s);
    for (char &c : s)
    {
        c = 'X';
    }
    cout << s <<endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <list>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    list<int> lst;
    vector<int> vec;
    int val;
    while (in >> val)
    {
        lst.push_back(val);
    }

    copy(lst.begin(), lst.end(), back_inserter(vec));

    cout << equal(lst.begin(), lst.end(), vec.begin()) << endl;
    for (auto iter = vec.begin(); iter != vec.end(); iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;
    return 0;
}
#include <iostream>
#include <vector>
#include <algorithm>
using namespace std;

int main(int argc, char *argv[])
{
    vector<int> vec;
    vec.reserve(10);
    fill_n(back_inserter(vec), 10, 0);

    for (auto iter = vec.begin(); iter != vec.end(); iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;
    return 0;
}
#include <iostream>

int main()
{
    std::cout<<"2\x4d\012";		//杈撳嚭2M锛岀劧鍚庢崲琛?
    std::cout<<"2\tM\n";		//杈撳嚭2銆佸埗琛ㄧ銆丮锛岀劧鍚庢崲琛?
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    string s;
    cout << "请输入一个字符串，可以包含空格：" << endl;
    getline(cin, s);
    int i = 0;
    while (s[i] != '\0')
    {
        s[i] = 'X';
        ++i;
    }
    cout << s <<endl;
    return 0;
}
#include <iostream>
#include <string>
using namespace std;

int main()
{
    string s;
    cout << "请输入一个字符串，可以包含空格：" << endl;
    getline(cin, s);
    for (unsigned int i = 0; i < s.size(); i++)
    {
        s[i] = 'X';
    }
    cout << s <<endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <set>
#include <string>
#include <algorithm>
using namespace std;

string &trans(string &s)
{
    for (int p = 0; p < s.size(); p++)
    {
        if (s[p] >= 'A' && s[p] <= 'Z')
        {
            s[p] -= ('A' - 'a');
        }
        else if (s[p] == ',' || s[p] == '.')
        {
            s.erase(p, 1);
        }
    }
    return s;
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    set<string> unique_word;
    string word;
    while (in >> word)
    {
        trans(word);
        unique_word.insert(word);
    }

  	for (const auto &w : unique_word)
    {
  	   	cout << w << " ";
    }
    cout << endl;
    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

string &trans(string &s)
{
    for (int p = 0; p < s.size(); p++)
    {
        if (s[p] >= 'A' && s[p] <= 'Z')
        {
            s[p] -= ('A' - 'a');
        }
        else if (s[p] == ',' || s[p] == '.')
        {
            s.erase(p, 1);
        }
    }
    return s;
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<string> unique_word;
    string word;
    while (in >> word)
    {
        trans(word);
        if (find(unique_word.begin(), unique_word.end(), word) == unique_word.end())
        {
            unique_word.push_back(word);
        }
    }

  	for (const auto &w : unique_word)
    {
  	   	cout << w << " ";
    }
    cout << endl;
    return 0;
}
#include <iostream>
using namespace std;

int main()
{
    unsigned int vowelCnt = 0;
    char ch;
    cout << "请输入一段文本：" << endl;
    while (cin >> ch)
    {
        if (ch == 'a')
        {
            ++vowelCnt;
        }
        if (ch == 'e')
        {
            ++vowelCnt;
        }
        if (ch == 'i')
        {
            ++vowelCnt;
        }
        if (ch == 'o')
        {
            ++vowelCnt;
        }
        if (ch == 'u')
        {
            ++vowelCnt;
        }
    }
    cout << "您输入的文本中共有 " << vowelCnt << "个元音字母" << endl;
    return 0;
}
#include <iostream>
#include <sstream>
#include <string>
#include <stdexcept>
using namespace std;

istream& f(istream &in)
{
    string v;
    while (in >> v, !in.eof())  // 直到遇到文件结束符才停止读取
    {
        if (in.bad())
        {
            throw runtime_error("IO流错误");
        }

        if (in.fail())
        {
            cerr << "数据错误，请重试：" << endl;
            in.clear();
            in.ignore(100, '\n');
            continue;
        }
        cout << v << endl;
    }
    in.clear();
    return in;
}

int main()
{
    ostringstream msg;
    msg << "C++ Primer 第五版" << endl;
    istringstream in(msg.str());
    f(in);
    return 0;
}
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

inline void output_words(vector<string> &words)
{
    for (auto iter = words.begin(); iter != words.end(); iter++)
    {
        cout << *iter << " ";
    }
    cout << endl;
}

void elimDups(vector<string> &words)
{
    output_words(words);

    sort(words.begin(), words.end());
    output_words(words);

    auto end_unique = unique(words.begin(), words.end());
    output_words(words);

    words.erase(end_unique, words.end());
    output_words(words);
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    vector<string> words;
    string word;
    while (in >> word)
    {
        words.push_back(word);
    }

    elimDups(words);
    return 0;
}
#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <list>
#include <string>
#include <algorithm>
using namespace std;

string &trans(string &s)
{
    for (int p = 0; p < s.size(); p++)
    {
        if (s[p] >= 'A' && s[p] <= 'Z')
        {
            s[p] -= ('A' - 'a');
        }
        else if (s[p] == ',' || s[p] == '.')
        {
            s.erase(p, 1);
        }
    }
    return s;
}

int main(int argc, char *argv[])
{
    ifstream in(argv[1]);
    if (!in)
    {
        cout << "打开输入文件失败！" << endl;
        exit(1);
    }

    map<string, list<int>> word_lineno; // 单词到行号的映射
    string line;
    string word;
    int lineno = 0;
    while (getline(in, line))
    {
        lineno++;                   // 行号递增
        istringstream l_in(line);   // 构造字符串流，读取单词
        while (l_in >> word)
        {
            trans(word);
            word_lineno[word].push_back(lineno);  // 添加行号
        }
    }

  	for (const auto &w : word_lineno)
    {
    		cout << w.first << "所在行：";
    		for (const auto &i : w.second)
        {
            cout << i << " ";
        }
        cout << endl;
  	}

    return 0;
}
#include <iostream>
#include <typeinfo>
using namespace std;

class Base {};
class Derived : public Base {};

int main()
{
    Base b, *pb;
    pb = NULL;
    Derived d;

    cout << typeid(int).name() << endl
         << typeid(unsigned).name() << endl
         << typeid(long).name() << endl
         << typeid(unsigned long).name() << endl
         << typeid(char).name() << endl
         << typeid(unsigned char).name() << endl
         << typeid(float).name() << endl
         << typeid(double).name() << endl
         << typeid(string).name() << endl
         << typeid(Base).name() << endl
         << typeid(b).name() << endl
         << typeid(pb).name() << endl
         << typeid(Derived).name() << endl
         << typeid(d).name() << endl
         << typeid(type_info).name() << endl;

    return 0;
}
#include <iostream>

int main()
{
    int sum = 0;
    int i = 50;
    while (i <= 100)
    {
        sum += i;
        i++;
    }
    std::cout << "50到100之间的整数之和为" << sum << std::endl;
    return 0;
}
#include "Chapter6.h"
using namespace std;

int fact(int val)
{
    if(val < 0)
        return -1;
    int ret = 1;
    //′ó1á?3?μ?val
    for(int i = 1; i != val + 1; ++i)
        ret *= i;
    return ret;
}
#include <iostream>
#include "Chapter6.h"
using namespace std;

int main()
{
    int num;
    cout << "请输入一个整数：";
    cin >> num;
    cout << num << "的阶乘是：" << fact(num) << endl;
    return 0;
}

#include "dd_TextQuery.h"
#include "make_plural.h"
#include "DebugDelete.h"

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
TextQuery::TextQuery(ifstream &is): file(new vector<string>, DebugDelete("shared_ptr"))
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
    cout << "enter a word to search for, or q to quit, or h to history: ";
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
    cout << "enter a word to search for, or q to quit, or h to history: ";
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

#include "Query.h"
#include "TextQuery.h"
#include <string>
#include <set>
#include <iostream>
#include <vector>

using std::set;
using std::string;
using std::cin;
using std::cout;
using std::cerr;
using std::endl;
using std::vector; using std::array;

int main(int argc, char **argv)
{
    // gets file to read and builds map to support queries
    TextQuery file = get_file(argc, argv);
    vector<array<string, 3>> h;

    // iterate with the user: prompt for a word to find and print results
    while (true)
    {
        string sought1, sought2, sought3;
        if (!get_word(sought1))
        {
            break;
        }

        if (sought1 != "h")
        {
            cout << "\nenter second and third words: " ;
            cin  >> sought2 >> sought3;
            // find all the occurrences of the requested string
            Query q = Query(sought1) & Query(sought2) | Query(sought3);
            h.push_back({sought1, sought2, sought3});
            cout << "\nExecuting Query for: " << q << endl;
            const auto results = q.eval(file);
            // report matches
            print(cout, results);
        }
        else        // 用户输入了"h"，表示要提取历史查询
        {
            cout << "\nenter Query no.: ";
            int i;
            cin >> i;
            if (i < 1 || i > h.size())    // 历史编号合法性检查
            {
                cout << "\nBad Query no." << endl;
            }
            else
            {
                // 提取三个查询词，重构查询
                Query q = Query(h[i-1][0]) & Query(h[i-1][1]) | Query(h[i-1][2]);;
                cout << "\nExecuting Query for: " << q << endl;
                const auto results = q.eval(file);
                // report matches
                print(cout, results);
            }
        }
    }
    return 0;
}
#include "Query.h"
#include "TextQuery.h"
#include <string>
#include <set>
#include <iostream>
#include <vector>

using std::set;
using std::string;
using std::cin;
using std::cout;
using std::cerr;
using std::endl;
using std::vector; using std::array;

int main(int argc, char **argv)
{
    // gets file to read and builds map to support queries
    TextQuery file = get_file(argc, argv);
    vector<array<string, 3>> h;

    // iterate with the user: prompt for a word to find and print results
    while (true)
    {
        string sought1, sought2, sought3;
        if (!get_word(sought1))
        {
            break;
        }

        if (sought1 != "h")
        {
            cout << "\nenter second and third words: " ;
            cin  >> sought2 >> sought3;
            // find all the occurrences of the requested string
            Query q = (Query(sought1) & Query(sought2)) | Query(sought3);
            h.push_back({sought1, sought2, sought3});
            cout << "\nExecuting Query for: " << q << endl;
            const auto results = q.eval(file);
            // report matches
            print(cout, results);
        }
        else        // 用户输入了"h"，表示要提取历史查询
        {
            cout << "\nenter Query no.: ";
            int i;
            cin >> i;
            if (i < 1 || i > h.size())    // 历史编号合法性检查
            {
                cout << "\nBad Query no." << endl;
            }
            else
            {
                // 提取三个查询词，重构查询
                Query q = (Query(h[i-1][0]) & Query(h[i-1][1])) | Query(h[i-1][2]);;
                cout << "\nExecuting Query for: " << q << endl;
                const auto results = q.eval(file);
                // report matches
                print(cout, results);
            }
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
#include "my_TextQuery.h"
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
		file.push_back(text);        // remember this line of text
		int n = file.size() - 1;     // the current line number
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
		   << qr.file.begin().deref(num) << endl;

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
#include "Sales_data.h"
#include <string>
using std::istream;
using std::ostream;

Sales_data::Sales_data(istream &is)
{
	is >> *this; // read a transaction from is into this object
}

double Sales_data::avg_price() const
{
	if (units_sold)
	{
		return revenue/units_sold;
	}
	else
	{
		return 0;
	}
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
Sales_data operator+(const Sales_data &lhs, const Sales_data &rhs)
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
	{
    	item.revenue = item.units_sold * price;
	}
	else
	{
    	item = Sales_data(); // input failed: give the object the default state
	}
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
	os << item.isbn() << " " << item.units_sold << " " << item.revenue << " " << item.avg_price();
	return os;
}

Sales_data add(const Sales_data &lhs, const Sales_data &rhs)
{
	Sales_data sum = lhs;  // copy data members from lhs into sum
	sum += rhs;            // add rhs into sum
	return sum;
}
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

#include <iostream>
using std::istream; using std::ostream;

#include "Sales_data.h"
Sales_data::Sales_data(std::istream &is)
{
	// read will read a transaction from is into this object
	read(is, *this);
}

double Sales_data::avg_price() const
{
	if (units_sold)
	{
		return revenue/units_sold;
	}
	else
	{
		return 0;
	}
}

// add the value of the given Sales_data into this object
Sales_data& Sales_data::combine(const Sales_data &rhs)
{
	units_sold += rhs.units_sold; // add the members of rhs into
	revenue += rhs.revenue;       // the members of ``this'' object
	return *this; // return the object on which the function was called
}

Sales_data add(const Sales_data &lhs, const Sales_data &rhs)
{
	Sales_data sum = lhs;  // copy data members from lhs into sum
	sum.combine(rhs);      // add data members from rhs into sum
	return sum;
}

// transactions contain ISBN, number of copies sold, and sales price
istream& read(istream &is, Sales_data &item)
{
	double price = 0;
	is >> item.bookNo >> item.units_sold >> price;
	item.revenue = price * item.units_sold;
	return is;
}

ostream& print(ostream &os, const Sales_data &item)
{
	os << item.isbn() << " " << item.units_sold << " "
	   << item.revenue << " " << item.avg_price();
	return os;
}
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
   std::cout << "Copy Assignment " << rhs.p << std::endl;
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
   std::cout << "Move Assignment " << rhs.p << std::endl;
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

#include "StrVec.h"
using namespace std;

void StrVec::push_back(const string& s)
{
    chk_n_alloc();  // 纭繚鏈夌┖闂村绾虫柊鍏冪礌
    alloc.construct(first_free++, s);  // 鍦╢irst_free鎸囧悜鐨勫厓绱犱腑鏋勯€爏鐨勫壇鏈?
}

pair<string*, string*> StrVec::alloc_n_copy(const string *b, const string *e)
{
    // 鍒嗛厤绌洪棿淇濆瓨缁欏畾鑼冨洿涓殑鍏冪礌
    // auto data = alloc.allocate(e - b);
    auto data = static_cast<string*>(operator new[]((e - b) * sizeof(string)));
    // 鍒濆鍖栧苟杩斿洖涓€涓猵air锛岃pair鐢眃ata鍜寀ninitialized_copy鐨勮繑鍥炲€兼瀯鎴?
    return {data, uninitialized_copy(b, e, data)};
}

void StrVec::free()
{
    // 涓嶈兘浼犻€掔粰deallocate涓€涓┖鎸囬拡锛屽鏋渆lements涓?锛屽嚱鏁颁粈涔堜篃涓嶅仛
    if (elements)
    {
        // 閫嗗簭閿€姣佹棫鍏冪礌
        for (auto p = first_free; p != elements; /* 绌?*/)
        {
            alloc.destroy(--p);
        }
        // alloc.deallocate(elements, cap - elements);
        operator delete[](elements);
    }
}

StrVec::StrVec(const StrVec &s)
{
    // 璋冪敤alloc_n_copy鍒嗛厤绌洪棿浠ュ绾充笌s涓竴鏍峰鐨勫厓绱?
    auto newdata = alloc_n_copy(s.begin(), s.end());
    elements = newdata.first;
    first_free = cap = newdata.second;
}

StrVec::~StrVec()
{
    free();
}

StrVec &StrVec::operator=(const StrVec &rhs)
{
    // 璋冪敤alloc_n_copy鍒嗛厤鍐呭瓨锛屽ぇ灏忎笌rhs涓厓绱犲崰鐢ㄧ┖闂翠竴鏍峰
    auto data = alloc_n_copy(rhs.begin(), rhs.end());
    free();
    elements = data.first;
    first_free = cap = data.second;
    return *this;
}

void StrVec::reallocate()
{
    // 鎴戜滑灏嗗垎閰嶅綋鍓嶅ぇ灏忎袱鍊嶇殑鍐呭瓨绌洪棿
    auto newcapacity = size() ? 2 * size() : 1;
    // 鍒嗛厤鏂板唴瀛?
    // auto newdata = alloc.allocate(newcapacity);
    auto newdata = static_cast<string*>(operator new[](newcapacity * sizeof(string)));
    // 灏嗘暟鎹粠鏃у唴瀛樼Щ鍔ㄥ埌鏂板唴瀛?
    auto dest = newdata;  // 鎸囧悜鏂版暟缁勪腑涓嬩竴涓┖闂蹭綅缃?
    auto elem = elements;  // 鎸囧悜鏃ф暟缁勪腑涓嬩竴涓厓绱?
    for (size_t i = 0; i != size(); ++i)
    {
        alloc.construct(dest++, std::move(*elem++));
    }
    free();  // 涓€鏃︽垜浠Щ鍔ㄥ畬鍏冪礌灏遍噴鏀炬棫鍐呭瓨绌洪棿
    // 鏇存柊鎴戜滑鐨勬暟鎹粨鏋勶紝鎵ц鏂板厓绱?
    elements = newdata;
    first_free = dest;
    cap = elements + newcapacity;
}

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
#include "strvec_TextQuery.h"
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
TextQuery::TextQuery(ifstream &is): file(new StrVec)
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
    char ws[]={'\t','\r','\v','\f','\n'};
    char eos[]={'?','.','!'};
    set<char> whiteSpace(ws,ws+5);   //空白符
    set<char> endOfSentence(eos,eos+3);   //句子结束符
    string sentence;
    char ch;

    while(is.get(ch))
    {
        //未遇到文件结束符
        if(!whiteSpace.count(ch))   //非空白符
        {
            sentence+=ch;
        }

        if(endOfSentence.count(ch))  //读完了一个句子
        {
            file->push_back(sentence);
            int n = file->size() - 1;
            istringstream is(sentence);
            string word;
            while (is >> word)
            {
                auto &lines = wm[word];
                if (!lines)
                {
                    lines.reset(new set<line_no>);
                }
                lines->insert(n);
            }
            sentence.assign("");   //将sentence清空，准备读下一个句子
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
    {
        os << "\t(sentence " << num + 1 << ") " << *(qr.file->begin() + num) << endl;
    }

	  return os;
}

// debugging routine, not covered in the book
void TextQuery::display_map()
{
    auto iter = wm.cbegin(), iter_end = wm.cend();

    // for each word in the map
    for ( ; iter != iter_end; ++iter)
    {
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

ostream &print(ostream & os, const QueryResult &qr, int beg, int end)
{
    // if the word was found, print the count and all occurrences
    os << qr.sought << " occurs " << qr.lines->size() << " "
       << make_plural(qr.lines->size(), "time", "s") << endl;

    // print each line in which the word appeared
	for (auto num : *qr.lines) // for every element in the set
		// don't confound the user with text lines starting at 0
		if (num + 1 >= beg && num + 1 <= end)
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

#include "token.h"

Token(Token &&other) : tok(INT), ival(0)
{
    tok = other.tok;
    ival = other.ival;
    other.tok = INT;
    other.ival = 0;
}

Token &operator=(Token &&other)
{
    if (this != &other)
    {
        delete tok;
        tok = other.tok;
        ival = other.ival;
        other.tok = INT;
        other.ival = 0;
    }

    return *this;
}

Token &Token::operator=(int i)
{
    if (tok == SDATA)  // 濡傛灉褰撳墠瀛樺偍鐨勬槸Sales_data锛岄噴鏀惧畠
    {
        sval.~Sales_data();
    }

    ival = i;  // 涓烘垚鍛樿祴鍊?
    tok = INT;  // 鏇存柊鍒ゅ埆寮?
    return *this;
}

Token &Token::operator=(char c)
{
    if (tok == SDATA)  // 濡傛灉褰撳墠瀛樺偍鐨勬槸Sales_data锛岄噴鏀惧畠
    {
        sval.~Sales_data();
    }

    cval = c;  // 涓烘垚鍛樿祴鍊?
    tok = CHAR;  // 鏇存柊鍒ゅ埆寮?
    return *this;
}

Token &Token::operator=(double d)
{
    if (tok == SDATA)  // 濡傛灉褰撳墠瀛樺偍鐨勬槸Sales_data锛岄噴鏀惧畠
    {
        sval.~Sales_data();
    }

    dval = d;  // 涓烘垚鍛樿祴鍊?
    tok = DBL;  // 鏇存柊鍒ゅ埆寮?
    return *this;
}

Token &Token::operator=(const Sales_data &sd)
{
    if (tok == SDATA)  // 濡傛灉褰撳墠瀛樺偍鐨勬槸Sales_data锛屽彲浠ョ洿鎺ヨ祴鍊?
    {
        sval = sd;
    }
    else  // 鍚﹀垯闇€瑕佸厛鏋勯€犱竴涓猄ales_data
    {
        new (&sval) Sales_data(sd);
    }

    tok = SDATA;  // 鏇存柊鍒ゅ埆寮?
    return *this;
}

void Token::copyUnion(const Token &t)
{
    swith (t.tok)
    {
        case Token::INT:
            ival = t.ival;
            break;

        case Token::CHAR:
            cval = t.cval;
            break;

        case Token::DBL:
            dval = t.dval;
            break;

        case Token::SDATA:
            new(&sval) Sales_data(t.sval);
            break;
    }
}

Token &Token::operator=(const Token &t)
{
    // 濡傛灉this 姝ゅ璞＄殑鍊兼槸string鑰宼鐨勫€间笉鏄紝鍒欐垜浠繀椤婚噴鏀惧師鏉ョ殑string
    if (tok == SDATA && t.tok != SDATA)
    {
        sval.~Sales_data();
    }

    if (tok == SDATA && t.tok == SDATA)
    {
        sval = t.sval;  // 鏃犻渶鏋勯€犱竴涓柊string
    }
    else
    {
        copyUnion(t);  // 濡傛灉t.tok鏄疭TR锛屽垯闇€瑕佹瀯閫犱竴涓猻tring
    }

    tok = t.tok;
    return *this;
}

#include "token.h"

Token(Token &&other) : tok(INT), ival(0)
{
    tok = other.tok;
    ival = other.ival;
    other.tok = INT;
    other.ival = 0;
}

Token &operator=(Token &&other)
{
    if (this != &other)
    {
        delete tok;
        tok = other.tok;
        ival = other.ival;
        other.tok = INT;
        other.ival = 0;
    }

    return *this;
}

Token &Token::operator=(int i)
{
    if (tok == SDATA)  // 濡傛灉褰撳墠瀛樺偍鐨勬槸Sales_data锛岄噴鏀惧畠
    {
        sval.~Sales_data();
    }

    ival = i;  // 涓烘垚鍛樿祴鍊?
    tok = INT;  // 鏇存柊鍒ゅ埆寮?
    return *this;
}

Token &Token::operator=(char c)
{
    if (tok == SDATA)  // 濡傛灉褰撳墠瀛樺偍鐨勬槸Sales_data锛岄噴鏀惧畠
    {
        sval.~Sales_data();
    }

    cval = c;  // 涓烘垚鍛樿祴鍊?
    tok = CHAR;  // 鏇存柊鍒ゅ埆寮?
    return *this;
}

Token &Token::operator=(double d)
{
    if (tok == SDATA)  // 濡傛灉褰撳墠瀛樺偍鐨勬槸Sales_data锛岄噴鏀惧畠
    {
        sval.~Sales_data();
    }

    dval = d;  // 涓烘垚鍛樿祴鍊?
    tok = DBL;  // 鏇存柊鍒ゅ埆寮?
    return *this;
}

Token &Token::operator=(const Sales_data &sd)
{
    if (tok == SDATA)  // 濡傛灉褰撳墠瀛樺偍鐨勬槸Sales_data锛屽彲浠ョ洿鎺ヨ祴鍊?
    {
        sval = sd;
    }
    else  // 鍚﹀垯闇€瑕佸厛鏋勯€犱竴涓猄ales_data
    {
        new (&sval) Sales_data(sd);
    }

    tok = SDATA;  // 鏇存柊鍒ゅ埆寮?
    return *this;
}

void Token::copyUnion(const Token &t)
{
    swith (t.tok)
    {
        case Token::INT:
            ival = t.ival;
            break;

        case Token::CHAR:
            cval = t.cval;
            break;

        case Token::DBL:
            dval = t.dval;
            break;

        case Token::SDATA:
            new(&sval) Sales_data(t.sval);
            break;
    }
}

Token &Token::operator=(const Token &t)
{
    // 濡傛灉this 姝ゅ璞＄殑鍊兼槸string鑰宼鐨勫€间笉鏄紝鍒欐垜浠繀椤婚噴鏀惧師鏉ョ殑string
    if (tok == SDATA && t.tok != SDATA)
    {
        sval.~Sales_data();
    }

    if (tok == SDATA && t.tok == SDATA)
    {
        sval = t.sval;  // 鏃犻渶鏋勯€犱竴涓柊string
    }
    else
    {
        copyUnion(t);  // 濡傛灉t.tok鏄疭TR锛屽垯闇€瑕佹瀯閫犱竴涓猻tring
    }

    tok = t.tok;
    return *this;
}

#include "token.h"

Token &Token::operator=(int i)
{
    if (tok == SDATA)  // 濡傛灉褰撳墠瀛樺偍鐨勬槸Sales_data锛岄噴鏀惧畠
    {
        sval.~Sales_data();
    }

    ival = i;  // 涓烘垚鍛樿祴鍊?
    tok = INT;  // 鏇存柊鍒ゅ埆寮?
    return *this;
}

Token &Token::operator=(char c)
{
    if (tok == SDATA)  // 濡傛灉褰撳墠瀛樺偍鐨勬槸Sales_data锛岄噴鏀惧畠
    {
        sval.~Sales_data();
    }

    cval = c;  // 涓烘垚鍛樿祴鍊?
    tok = CHAR;  // 鏇存柊鍒ゅ埆寮?
    return *this;
}

Token &Token::operator=(double d)
{
    if (tok == SDATA)  // 濡傛灉褰撳墠瀛樺偍鐨勬槸Sales_data锛岄噴鏀惧畠
    {
        sval.~Sales_data();
    }

    dval = d;  // 涓烘垚鍛樿祴鍊?
    tok = DBL;  // 鏇存柊鍒ゅ埆寮?
    return *this;
}

Token &Token::operator=(const Sales_data &sd)
{
    if (tok == SDATA)  // 濡傛灉褰撳墠瀛樺偍鐨勬槸Sales_data锛屽彲浠ョ洿鎺ヨ祴鍊?
    {
        sval = sd;
    }
    else  // 鍚﹀垯闇€瑕佸厛鏋勯€犱竴涓猄ales_data
    {
        new (&sval) Sales_data(sd);
    }

    tok = SDATA;  // 鏇存柊鍒ゅ埆寮?
    return *this;
}

void Token::copyUnion(const Token &t)
{
    swith (t.tok)
    {
        case Token::INT:
            ival = t.ival;
            break;

        case Token::CHAR:
            cval = t.cval;
            break;

        case Token::DBL:
            dval = t.dval;
            break;

        case Token::SDATA:
            new(&sval) Sales_data(t.sval);
            break;
    }
}

Token &Token::operator=(const Token &t)
{
    // 濡傛灉this 姝ゅ璞＄殑鍊兼槸string鑰宼鐨勫€间笉鏄紝鍒欐垜浠繀椤婚噴鏀惧師鏉ョ殑string
    if (tok == SDATA && t.tok != SDATA)
    {
        sval.~Sales_data();
    }

    if (tok == SDATA && t.tok == SDATA)
    {
        sval = t.sval;  // 鏃犻渶鏋勯€犱竴涓柊string
    }
    else
    {
        copyUnion(t);  // 濡傛灉t.tok鏄疭TR锛屽垯闇€瑕佹瀯閫犱竴涓猻tring
    }

    tok = t.tok;
    return *this;
}

#include "t_TextQuery.h"
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
using std::get;

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
    os << get<0>(qr) << " occurs " << get<1>(qr)->size() << " "
       << make_plural(get<1>(qr)->size(), "time", "s") << endl;

    // print each line in which the word appeared
	for (auto num : *get<1>(qr)) // for every element in the set
		// don't confound the user with text lines starting at 0
        os << "\t(line " << num + 1 << ") "
		   << *(get<2>(qr)->begin() + num) << endl;

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