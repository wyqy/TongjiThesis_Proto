\NeedsTeXFormat{LaTeX2e}[1999/12/01]
\ProvidesClass{tongjithesis}[2018/02/15 2 Tongji University Thesis Template]
\hyphenation{Tongji-Thesis}
% basic definition
\def\tongjithesis{\textsc{TongjiThesis}} % \textsc 将所有字符大写. 用于强调
\def\version{2}

% 工具宏包
\RequirePackage{ifxetex} % 判断是否为 xetex
\RequirePackage{filehook} % 魔改宏包
\RequirePackage{xstring} % 字符串处理宏包
\RequirePackage{etoolbox} % LATEX kernel commands 的不同实现
\RequirePackage{xparse} % \newcommand 的替代: \NewDocumentCommand

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 读取配置选项 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 读取配置
\RequirePackage{kvoptions}
\SetupKeyvalOptions{
  family=tongji,
  prefix=tongji@,
  setkeys=\kvsetkeys}

% COVERLETTERR 配置
% 注意 \define@key 的语法, 即 \define@key{fam}{key}{ 对参数 #1 的处理,即 handler}
% 使用 kvoptions 的 \define@key 之后, 就可以以 key-val 的方式设置封面的数据了
\def\tongji@def@term#1{%
  \define@key{tongji}{#1}{\csname #1\endcsname{##1}}
  \expandafter\gdef\csname #1\endcsname##1{%
    \expandafter\gdef\csname tongji@#1\endcsname{##1}}
  \csname #1\endcsname{}}
% 解析: 假设我们使用\tongji@def@term{secretlevel}, 展开之后就是: 
% \define@key{tongji}{secretlevel}{\secretlevel{#1}} \gdef\secretlevel#1{\gdef\tongji@secretlevel{#1}} \secretlevel{}
% 前辈们很明智地定义了三个东西, 不设置的时候为空. 还可以手动设置. 很强啊
\tongji@def@term{secretlevel}                                           % 密级参数
\tongji@def@term{secretyear}                                            % 解密年份
\tongji@def@term{ctitle}            \tongji@def@term{etitle}            % 题目中英文
\tongji@def@term{cauthor}           \tongji@def@term{eauthor}           % 作者中英文
\tongji@def@term{studentnumber}                                         % 学号
\tongji@def@term{csupervisor}       \tongji@def@term{esupervisor}       % 导师中英文
\tongji@def@term{cassosupervisor}   \tongji@def@term{eassosupervisor}   % 副导师(校外)老师中英文
\tongji@def@term{cjointinstitution} \tongji@def@term{ejointinstitution} % 培养机构中英文
\tongji@def@term{cdegree}           \tongji@def@term{edegree}           % 学位中英文
\tongji@def@term{csubjectcategory}  \tongji@def@term{esubjectcategory}  % 学科门类中英文
\tongji@def@term{cresearchfield}    \tongji@def@term{eresearchfield}    % 研究领域中英文
\tongji@def@term{cdepartment}       \tongji@def@term{edepartment}       % 院系中英文名称
\tongji@def@term{cmajor}            \tongji@def@term{emajor}            % 学位中英文名称
\tongji@def@term{cdate}             \tongji@def@term{edate}             % 论文成文日期
\tongji@def@term{cmajorfirst}       \tongji@def@term{emajorfirst}       % 学科门类, 如工学, 理学
\tongji@def@term{cmajorsecond}      \tongji@def@term{emajorsecond}      % 一级学科或二级学科
\tongji@def@term{cfunds}            \tongji@def@term{efunds}            % 基金支持中英文
% 通过 \cs{tongjisetup} 以 key / value 的方式统一设置封面信息, 需要在 \cs{makecover} 之前被调用
\def\tongjisetup{\kvsetkeys{tongji}}  % key 不支持环境项, 如 \texttt{cabstract} 和 \texttt{eabstract}

% 模板配置选项
% (必选) 学位类别: degree=[master|doctor]
\newif\iftongji@master
\newif\iftongji@doctor
\define@key{tongji}{degree}{%
  \tongji@masterfalse \tongji@doctorfalse
  \expandafter\csname tongji@#1true\endcsname}

% (可选) 引用格式: bibtype=[numeric|authoryear] ( 数字式引用 或 作者-年份引用 )
\newif\iftongji@numeric \tongji@numerictrue  % 数字式引用 (默认)
\newif\iftongji@authoryear  % 作者-年份引用
\define@key{tongji}{bibtype}{%
  \tongji@numericfalse \tongji@authoryearfalse
  \expandafter\csname tongji@#1true\endcsname}

% (可选) 硕士学位类别: degreetype=[academic|profession|equaleducation] ( 学术型 或 专业型 或 同等学力 )
\newif\iftongji@academic \tongji@academictrue  % 学术型 (默认)
\newif\iftongji@profession  % 专业型
\newif\iftongji@equaleducation  % 同等学力
\define@key{tongji}{degreetype}{%
  \tongji@academicfalse \tongji@professionfalse \tongji@equaleducationfalse
  \expandafter\csname tongji@#1true\endcsname}

% (可选) 电子版标注: electronic / 打印时删除
\DeclareBoolOption{electronic}  % 默认为 false (不显示)

% (可选) 保密标注: 秘密 / 机密/ 绝密 ( 请同时在 cover.tex 中配置相应选项 )
\DeclareBoolOption{secret}  % 默认为 false (不显示)

% (可选) 页眉格式: false = 传统格式 / true = 新格式
\DeclareBoolOption{styleheadercentered}  % 默认为 true (新格式)

% 强制使用 windows 风格字体, 然后映射到目录下的字体文件
\IfFileExists{/dev/null}{}{\PassOptionsToClass{fontset=windows}{ctexbook}}  % simhei 字体

% ctexbook 配置
% tex 默认会尽量使得所有 page 的 bottom margins 相等, raggedbottom 允许不同 page 的 bottom margins 不一样, 防止大段材料跨页
\DeclareBoolOption{raggedbottom}
% 在脚注标记中使用 \pkg{pifont} 的带圈数字(默认打开), 此选项生成的带圈数字更漂亮
\DeclareBoolOption{pifootnote}
\DeclareDefaultOption{\PassOptionsToClass{\CurrentOption}{ctexbook}} % 将选项传递给 \pkg{ctexbook}

% 解析用户传递过来的选项, 并加载 \pkg{ctexbook}
% 强制指定一个degree选项
\ProcessKeyvalOptions*
  \iftongji@master\relax\else
    \iftongji@doctor\relax\else
        \ClassError{tongjithesis}%
                   {Please specify thesis degree in option: \MessageBreak
                    degree=[master | doctor]}{}      
    \fi
  \fi
% 杜绝非法的degreetype选项
\iftongji@academic\relax\else
  \iftongji@profession\relax\else
    \iftongji@equaleducation\relax\else
        \ClassError{tongjithesis}{Unknown degree type option.\MessageBreak Please check your degree type option, good luck!}{}  
    \fi
  \fi
\fi
% 杜绝非法的bibtype选项
\iftongji@numeric\relax\else
  \iftongji@authoryear\relax\else    
      \ClassError{tongjithesis}{Unknown bib type option.\MessageBreak Please check your bib type option, good luck!}{}  
   \fi
\fi

% 打开默认选项
\kvsetkeys{tongji}{ raggedbottom, pifootnote, styleheadercentered }

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 中文语言支持 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 以往, 为LATEX 文档配置中文支持是一件相当繁琐的事情
% 默认情况下, CTEX 宏集能自动检测编译方式和操作系统, 选择合适的底层支持和字库, 从而简化配置过程
% 在 Windows 操作系统上, 采用的是中易字库 + 微软雅黑
% CTEX 宏集预定义的中文字库还定义了一些字体命令
% \songti, \heiti, \fangsong, \kaishu, \lishu, \youyuan, \yahei
% 等价的CJK命令为\CJKfamily{zhsong}等


% 将伪粗体与伪斜体的选项传递给xeCJK package
\PassOptionsToPackage{AutoFakeBold=1.2,AutoFakeSlant}{xeCJK}
% 使用CTeX宏包的默认中文字体配置, 支持不同引擎
\LoadClass[a4paper,openany,UTF8,zihao=-4,scheme=plain]{ctexbook}

% 使用XeTeX引擎时, \pkg{fontspec}宏包会被\pkg{xeCJK}自动调用
% 传递给 \pkg{fontspec} 宏包\option{no-math}选项, 避免部分数学符号字体自动调整为 CMR
\PassOptionsToPackage{no-math}{fontspec}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 一般宏包引用 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage{amsmath, amssymb} % \AmSTeX\ 宏包
\RequirePackage{mathtools} % 增强数学功能
% \RequirePackage{xfrac} % 更好的分式排版
\RequirePackage{nicematrix} % 更好的矩阵排版
\RequirePackage{pdfrender} % 更好的粗体渲染

% 使用其它数学字体
\RequirePackage{amsfonts}
% \RequirePackage{bm} % 处理数学公式中的黑斜体的替代
\RequirePackage{mathrsfs} % \mathscr
\RequirePackage[oldbold,%
  cal=dutchcal, calscaled=1.00,%
  scr=boondoxupr, scrscaled=1.00,%
  bb=libus, bbscaled=1.00]{mathalfa}
% \RequirePackage[utf8]{inputenc} % utf8 encoding, not used with xelatex
\RequirePackage[T2A, T1]{fontenc} % Cyrillic font
% 其它字体
\iftongji@pifootnote
  \RequirePackage{pifont}% pifont有很多Pi fonts, 如Dingbats(杂锦字体), Symbol, etc
\fi

% 图形支持宏包, 支持 eps
\RequirePackage{graphicx}
% tikz 绘制图形
\RequirePackage{tikz}
% 并排图形
\RequirePackage[labelformat=simple]{subcaption}

% \pkg{pdfpages} 宏包便于我们插入扫描后的授权页和声明页 PDF 文档
\RequirePackage{pdfpages}
\includepdfset{fitpaper=true}

% 更好的列表环境: enumerate, itemize and description
\RequirePackage[shortlabels]{enumitem}
% environ使得我们在创建新的环境的时候可以定义new author interface
\RequirePackage{environ}

% 禁止在留白页(\cs{cleardoublepage})上标记页眉页脚(页码)
\RequirePackage{emptypage} 

% 页眉页脚样式
% 禁止自动调整多余的页面底部空白
% 保持脚注仍然在底部, 并按页编号
\iftongji@raggedbottom
  \RequirePackage[bottom,perpage,hang]{footmisc}
  \raggedbottom
\else
  \RequirePackage[perpage,hang]{footmisc}
\fi

% 利用 \pkg{CJKfntef} 实现汉字的下划线和盒子内两段对齐, 并可以避免
% \cs{makebox}\oarg{width}\oarg{s} 可能产生的 underful boxes
\RequirePackage{CJKfntef}

% 定理类环境宏包, 其中 \pkg{amsmath} 选项用来兼容 \AmSTeX\ 的宏包
\RequirePackage[amsmath,thmmarks,hyperref]{ntheorem}

% 表格控制
\RequirePackage{array}
\RequirePackage{longtable}
% 使用三线表: \cs{toprule}, \cs{midrule}, \cs{bottomrule}
\RequirePackage{booktabs}
% 采用supertabular实现长表格分页显示
\RequirePackage{supertabular}
% 增强表格
\RequirePackage{threeparttable} % 允许脚注
\RequirePackage{multirow, makecell} % 表格中支持跨行/列
\RequirePackage{diagbox} % 表格中的反斜线
\RequirePackage{tabularx} % 方便定义宽度的表格
\RequirePackage{slashbox} % 表格中的反斜线

% 算法宏包
\let\old@chapter\@chapter % Store \@chapter
\RequirePackage[algochapter,linesnumbered,ruled]{algorithm2e}
\let\@chapter\old@chapter % Restore \@chapter % 避免章间空隙
% https://tex.stackexchange.com/questions/237388/remove-vertical-space-after-new-chapters-in-listofalgorithms

% 其它宏包
\RequirePackage[ntheorem]{empheq}
\RequirePackage{stackengine}
\RequirePackage{ulem, cases}

% 确定浮动对象的位置, 可以使用~H, 强制将浮动对象放到这里(可能效果很差)
\RequirePackage{float}
% 浮动图形控制宏包
% 允许上一个~section 的浮动图形出现在下一个~section 的开始部分
% 该宏包提供处理浮动对象的~|\FloatBarrier| 命令, 使所有未处理的浮动图形立即被处理
% 这三个宏包仅供参考, 未必使用: 
% \RequirePackage[below]{placeins}
% \RequirePackage{floatflt} % 图文混排用宏包
% \RequirePackage{rotating} % 图形和表格的控制旋转

% 参考文献引用: biblatex
\iftongji@numeric
  \RequirePackage[backend=biber,style=gb7714-2015,%
  gbnamefmt=familyahead,gbpub=false,isbn=false,doi=false,gbtitlelink=true,url=false,sortlocale=zh__pinyin]{biblatex} 
\else
  \iftongji@authoryear % 若需使用author-year格式的文献引用, 可将style选择为: gb7714-2015ay
    \RequirePackage[backend=biber,style=gb7714-2015ay,%
    gbnamefmt=familyahead,gbpub=false,isbn=false,doi=false,gbtitlelink=true,url=false,sortlocale=zh__pinyin,]{biblatex} 
  \fi
\fi
% 参考文献宏包的其他选项:
% gbpub=false: 用于去除参考文献中的出版地不详, 出版者不详等信息
% maxnames={int}: 设置所有作者都能够列出时, 允许的最大作者数量, 默认为3
% 后边 isbn 和 doi 选项略去
\DefineBibliographyStrings{english}{in={}}  % 去掉中文析出文献的 in 符号
\DefineBibliographyStrings{english}{incn={}} % 去掉中文析出文献的 // 符号

% 生成有书签的 pdf 及其开关, 请结合 gbk2uni 避免书签乱码
\RequirePackage{hyperref}
\ifxetex
  \hypersetup{%
    CJKbookmarks=true}
\else
  \hypersetup{%
    unicode=true,
    CJKbookmarks=false}
\fi
\hypersetup{%
  linktoc=all,
  bookmarksnumbered=true,
  bookmarksopen=true,
  bookmarksopenlevel=1,
  breaklinks=true,
  colorlinks=false,
  plainpages=false,
% pdfpagelabels, % 将\thepage写入pdf, 使得阅读器可以显示‘ii (4 of 40)’ rather than simply ‘4 of 40’, 新版TeX已默认开启
  pdfborder=0 0 0}
% 设置 url 样式, 与上下文一致
\urlstyle{same}

% 页面设置
\RequirePackage{geometry}
\geometry{
	a4paper, % 210 * 297mm
	hcentering, % 将hmarginratio设为1:1, 即left=right
	ignoreall, % body部分不包含top,bottom,left,right, 即textheight就是正文的高度
	textheight=246.2mm, % 297-25.4x2
	bottom=25.4mm,
	nomarginpar, % 即\marginparwidth=0pt and \marginparsep=0pt
	left=31.7mm, % 注意left=right
	headheight=5mm,
	headsep=5.4mm,	% 页眉距顶端要求 2cm. 即25.4-20=5.4
	footskip=5.4mm}	%\footskip指的是正文最后一行距离页脚的距离(baseline)

\RequirePackage{fancyhdr} % 利用 \pkg{fancyhdr} 设置页眉页脚
\RequirePackage{xspace} % 给自定义的宏后面自动加空白

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 文章字体设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 全文设置 songti + times
\RequirePackage{courier} % 使用 Courier 字体
\defaultfontfeatures{Mapping=tex-text} % 修复引号等字符的显示
% 强制使用 font 文件夹下自带字体
\setCJKfamilyfont{zhsong}[Path={fonts/}]{SimSun.ttf}  % \songti
\setCJKfamilyfont{zhhei}[Path={fonts/}]{SimHei.ttf}  % \heiti
\setCJKfamilyfont{zhfs}[Path={fonts/}]{FangSong_GB2312.ttf}  % \fangsong
\setCJKfamilyfont{zhkai}[Path={fonts/}]{KaiTi_GB2312.ttf}  % \kaishu
\setCJKfamilyfont{zhli}[Path={fonts/}]{LiShu.ttf}  % \lishu
\setmainfont{times.ttf}[
  Path = fonts/,
  BoldFont = timesbd.ttf,
  ItalicFont = timesi.ttf,
  BoldItalicFont = timesbi.ttf
]

% 标题设置 heiti + times
% 各级标题格式设置在本文件后边
% \def\tongji@title@font{\rmfamily}
\def\tongji@title@font{\heiti}

% 正文小四号 (12bp) 字, 行距为固定值 20 bp
\renewcommand\normalsize{%
  \@setfontsize\normalsize{12bp}{20bp}%
  \abovedisplayskip=10bp % 用来调整math相关的skip
  \@plus 2bp \@minus 2bp % 同样的功能, 详见The texbook
  
  \abovedisplayshortskip=10bp \@plus 2bp \@minus 2bp
  \belowdisplayskip=\abovedisplayskip
  \belowdisplayshortskip=\abovedisplayshortskip}
% \fontsize的内部实现就是: 
% \DeclareRobustCommand{\fontsize}[2]{\set@fontsize \baselinestretch {#1}{#2}}
% 而\@setfontsize具有三个参数, 对于我们上面的用法\@setfontsize\normalsize{12bp}{20bp}
% 展开为: 
% \@nomath\normalsize
% \ifx\protect\@typeset@protect\let\@currsize\normalsize\fi
% \fontsize{12bp}{20bp}\selectfont
% 第一行确保LaTeX to disallow \normalsize in math mode
% 第二行将\@currsize设为\normalsize, 第三行调用\fontsize, 字体12bp, 行距20bp
% 以上解释来自: https://tex.stackexchange.com/questions/112492/setfontsize-vs-fontsize

% 根据习惯定义字号
\def\tongji@define@fontsize#1#2{%
  \expandafter\newcommand\csname #1\endcsname[1][1.3]{%
    \fontsize{#2}{##1\dimexpr #2}\selectfont}}
% \fontsize{size}{skip} 其中, skip 就是行距
% \selectfont 用来使得字体的配置生效
% #1 \dimexpr #2 就是#1 和 #2相乘, 其中\dimexpr来自 etex, 目前的 tex 基本上都自带 (?)
% 举例说明: \tongji@define@fontsize{chuhao}{42bp} 展开就是这样: 
% \newcommand \chuhao [1][1.3]{\fontsize{42bp}{#1\dimexpr 42bp}\selectfont}}
% 其中, [1][1.3]表示只有一个参数, 该参数默认为1.3
\tongji@define@fontsize{chuhao}{42bp}
\tongji@define@fontsize{xiaochu}{36bp}
\tongji@define@fontsize{yihao}{26bp}
\tongji@define@fontsize{xiaoyi}{24bp}
\tongji@define@fontsize{erhao}{22bp}
\tongji@define@fontsize{xiaoer}{18bp}
\tongji@define@fontsize{sanhao}{16bp}
\tongji@define@fontsize{xiaosan}{15bp}
\tongji@define@fontsize{sihao}{14bp}
\tongji@define@fontsize{banxiaosi}{13bp}
\tongji@define@fontsize{xiaosi}{12bp}
\tongji@define@fontsize{dawu}{11bp}
\tongji@define@fontsize{wuhao}{10.5bp}
\tongji@define@fontsize{xiaowu}{9bp}
\tongji@define@fontsize{liuhao}{7.5bp}
\tongji@define@fontsize{xiaoliu}{6.5bp}
\tongji@define@fontsize{qihao}{5.5bp}
\tongji@define@fontsize{bahao}{5bp}

% 全文首行缩进2字符, 标点符号用全角
\ctexset{%
punct=quanjiao,
space=auto,
autoindent=true}
% \ctexset的详细介绍见"ctex宏集手册" (2018/01/28 v2.4.12)
% 它有很多实用选项, 如chapter/name = {第,章}, section/name = {\S}

% 利用 \pkg{enumitem} 命令调整默认列表环境间的距离, 以符合中文习惯
\setlist{nosep}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 文章页面设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 修改 \cs{chaptermark}, 导致页眉多余章号并且英文大写的问题
\AtBeginDocument{%
  \pagestyle{tongji@empty}
  \renewcommand{\chaptermark}[1]{%
    \wyqydeletelinebreaktxt{#1}{wyqy@chaptermark}
    \@mkboth{\CTEXthechapter\hskip\ccwd\wyqy@chaptermark}{}}}

% 定义页眉和页脚格式
% \texttt{tongji@empty}: 页眉页脚都没有
\fancypagestyle{tongji@empty}{%
  \fancyhf{}
  \renewcommand{\headrulewidth}{0pt}
  \renewcommand{\footrulewidth}{0pt}
  }

% \texttt{tongji@plain}: 只显示页脚的页码, 默认 \cs{chapter} 调用 \cs{tongji@plain}
\fancypagestyle{tongji@plain}{%
  \fancyhead{}
  \fancyfoot[C]{\songti\wuhao\thepage}
  \renewcommand{\headrulewidth}{0pt}
  \renewcommand{\footrulewidth}{0pt}}

% \texttt{tongji@headingmain}: 正文样式: 页眉页脚同时显示 ( 可选择是否页眉居中 )
\iftongji@styleheadercentered\def\xparameter@headingmain@odd{CO}\else\def\xparameter@headingmain@odd{RO}\fi
\iftongji@styleheadercentered\def\xparameter@headingmain@even{CE}\else\def\xparameter@headingmain@even{LE}\fi
\fancypagestyle{tongji@headingmain}{%
  \fancyhead{}
  \fancyhead[\xparameter@headingmain@odd]{\wuhao\songti\tongji@schoolname~\tongji@capply~\tongji@cheadingtitlenew}
  \fancyhead[\xparameter@headingmain@even]{\wuhao\songti\tongji@schoolname~\tongji@capply~\tongji@cheadingtitlenew}
  \fancyfoot{}
  \fancyfoot[C]{\songti\wuhao\thepage}
  \renewcommand{\headrulewidth}{0.4pt}
  \renewcommand{\footrulewidth}{0pt}}

% \texttt{tongji@headingref}: 参考文献样式: 页眉页脚同时显示, 但是页眉均为奇数页面格式 ( 可选择是否页眉居中 )
\fancypagestyle{tongji@headingref}{%
  \fancyhead{}
  \fancyhead[\xparameter@headingmain@odd]{\wuhao\songti\tongji@schoolname~\tongji@capply~\tongji@referencesname}
  \fancyhead[\xparameter@headingmain@even]{\wuhao\songti\tongji@schoolname~\tongji@capply~\tongji@referencesname}
  \fancyfoot{}
  \fancyfoot[C]{\songti\wuhao\thepage}
  \renewcommand{\headrulewidth}{0.4pt}
  \renewcommand{\footrulewidth}{0pt}}

% 定义样式
\renewcommand\frontmatter{%
  \clearpage
  \@mainmatterfalse
  \pagenumbering{Roman}
  \pagestyle{tongji@empty}
  }
% 注意 \mainmatter的heading 设置除此之外, 还有 \ctexset 的 pagestyle 域
\renewcommand\mainmatter{%
  \cleardoublepage % 强迫第一章的首页从右边开始, 在双面打印中, 即奇数页在右边
  \@mainmattertrue
  \pagenumbering{arabic}
  \pagestyle{tongji@headingmain}
  % \renewcommand\thesection{\arabic{chapter}.\ \arabic{section}} % 各级标题以及图标序号格式修改(增加序号中点后的空格)
  % \renewcommand\thesubsection{\arabic{chapter}.\ \arabic{section}.\ \arabic{subsection}}
  % \renewcommand\thesubsubsection{\arabic{chapter}.\ \arabic{section}.\ \arabic{subsection}.\ \arabic{subsubsection}}
  % \renewcommand\thefigure{\arabic{chapter}.\ \arabic{figure}}
  % \renewcommand\thetable{\arabic{chapter}.\ \arabic{table}}
  }
\renewcommand\backmatter{%
  \clearpage
  \@mainmattertrue
  % \renewcommand\thesection{\Alph{chapter}.\ \arabic{section}} % 附录中的 chapter 需要使用英文标号
  % \renewcommand\thesubsection{\Alph{chapter}.\ \arabic{section}.\ \arabic{subsection}}
  % \renewcommand\thesubsubsection{\Alph{chapter}.\ \arabic{section}.\ \arabic{subsection}.\ \arabic{subsubsection}}
  % \renewcommand\thefigure{\Alph{chapter}.\ \arabic{figure}}
  % \renewcommand\thetable{\Alph{chapter}.\ \arabic{table}}
  }

% 脚注部分
% 生成带圈的脚注数字, 最多处理到 10
\def\tongji@textcircled#1{%
  \ifnum\value{#1} >9
    \ClassError{tongjithesis}%
      {Too many footnotes in this page.}{Keep footnote less than 10.}
  \fi
  \iftongji@pifootnote%
    \ding{\the\numexpr\value{#1}+171\relax}%
  \else%
    \textcircled{\xiaoliu\arabic{#1}}%
  \fi}
\renewcommand{\thefootnote}{\tongji@textcircled{footnote}}
\renewcommand{\thempfootnote}{\tongji@textcircled{mpfootnote}}
% 关于 footnote marking 的更改, 可以参考: https://en.wikibooks.org/wiki/LaTeX/Footnotes_and_Margin_Notes		
% 定义脚注分割线, 字号(宋体小五), 以及悬挂缩进(1.5字符)
\def\footnoterule{\vskip-3\p@\hrule\@width0.3\textwidth\@height0.4\p@\vskip2.6\p@}
\let\tongji@footnotesize\footnotesize
\renewcommand\footnotesize{\tongji@footnotesize\xiaowu[1.5]}
\footnotemargin1.5em\relax
% \cs{@makefnmark} 默认是上标样式, 而在脚注部分要求为正文大小. 利用\cs{patchcmd}
% 动态调整 \cs{@makefnmark} 的定义
\let\tongji@makefnmark\@makefnmark
\def\tongji@@makefnmark{\hbox{{\normalfont\@thefnmark}}}
\pretocmd{\@makefntext}{\let\@makefnmark\tongji@@makefnmark}{}{}
\apptocmd{\@makefntext}{\let\@makefnmark\tongji@makefnmark}{}{}
% 为 \cs{footnote} 增加后空白
\let\oldfootnote\footnote
\renewcommand{\footnote}[1]{\oldfootnote{#1\vspace{2.1pt}}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 断行分页设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 允许太长的公式断行, 分页等
\allowdisplaybreaks[4]
\renewcommand\theequation{\ifnum \c@chapter>\z@ \thechapter.\fi\@arabic\c@equation}

% 公式距前后文的距离由 4 个参数控制, 参见 \cs{normalsize} 的定义
% 定理标题使用黑体, 正文使用宋体, 冒号隔开
% 定理环境格式设置(环境标题和环境正文字体设置)统一放置到 .cfg 文件中

% 设置浮动对象和文字之间的距离
% 语法举例: {10pt plus 1.0pt minus 2.0pt} The plus and minus parts allow the space to stretch or shrink (the greater they are, the more it stretches or shrinks when needed).
\setlength{\floatsep}{12bp \@plus4pt \@minus1pt} % vertical distance between two floats
\setlength{\intextsep}{12bp \@plus4pt \@minus2pt} % distance between floats inserted inside the page text (using h) and the text proper. 即, 对于插入正文中的float, 这个\intextsep指的是图片上部和下部距离正文的距离
\setlength{\textfloatsep}{12bp \@plus4pt \@minus2pt}%  distance between floats on the top or the bottom and the text
% 注: 清华的都设为20bp了, 而不是12bp, 我们tj的更紧凑一些
\setlength{\@fptop}{0bp \@plus1.0fil}
\setlength{\@fpsep}{12bp \@plus2.0fil}
\setlength{\@fpbot}{0bp \@plus1.0fil}

% 下面这组命令使浮动对象的缺省值稍微宽松一点, 从而防止浮动对象占据过多的文本页面, 
% 也可以防止在很大空白的浮动页上放置很小的图形
\renewcommand{\textfraction}{0.15} %即, 一个page的text的最小比例是0.15, 默认是0.2. 当然如果浮动对象占的比例太大, 就会移到另一个页面
\renewcommand{\topfraction}{0.85} %页面顶部至多有0.85的空间被浮动对象填充
\renewcommand{\bottomfraction}{0.65}%同理, 这个是底部的
\renewcommand{\floatpagefraction}{0.60}%一个float page(a page containing no text,
% only floats.)被浮动对象占的比例最少是0.6

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 图表样式设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 定制浮动图形和表格标题样式
% 图表标题字体为宋体五号
% 去掉图表号后面的冒号. 图序与图名文字之间空一个汉字符宽度
% 图: caption 在下, 段前空 6 磅, 段后空 12 磅, 单倍行距
% 表: caption 在上, 段前空 6 磅, 段后空 6 磅, 单倍行距
% 不管 caption 出现在什么位置, \cs{aboveskip} 总是出现在标题和浮动体之间的距离
\let\old@tabular\@tabular
\def\tongji@tabular{\wuhao[1.5]\old@tabular}
% 注: \DeclareCaptionLabelFormat 来自subcaption包
\DeclareCaptionLabelFormat{tongji}{{\wuhao[1.5]\normalfont #1~#2}}
\DeclareCaptionLabelSeparator{tongji}{\hspace{1em}}
\DeclareCaptionFont{tongji}{\wuhao[1.5]}
\captionsetup{labelformat=tongji,labelsep=tongji,font=tongji}
\captionsetup[table]{position=top,belowskip={12bp-\intextsep},aboveskip=6bp}
\captionsetup[figure]{position=bottom,belowskip={6bp-\intextsep},aboveskip=6bp}
\captionsetup[sub]{font=tongji,skip=6bp}
\renewcommand{\thesubfigure}{(\alph{subfigure})}
\renewcommand{\thesubtable}{(\alph{subtable})}

% 我们采用 \pkg{longtable} 来处理跨页的表格. 同样我们需要设置其默认字体为五号
\let\tongji@LT@array\LT@array
\def\LT@array{\wuhao[1.5]\tongji@LT@array} % set default font size

% 简单的表格使用三线表推荐用 \cs{hlinewd}
% 如果表格比较复杂还是用 \pkg{booktabs} 的命令好一些
\def\hlinewd#1{%
  \noalign{\ifnum0=`}\fi\hrule \@height #1 \futurelet
    \reserved@a\@xhline}

% 定义algorithm2e的字体
\newcommand\commentFont[1]{\ttfamily{#1}}
\newcommand{\tongji@algorithm@kwsty}{\xiaosi[2]\normalfont}
\AtEndOfPackageFile*{algorithm2e}{
  \SetCommentSty{commentFont}
  \SetKwSty{tongji@algorithm@kwsty}
  \SetArgSty{tongji@algorithm@kwsty}
  \SetAlFnt{\xiaosi[1.75]} % 字体: 算法正文
  \SetKwInput{KwData}{输入数据}
  \SetKwInput{KwResult}{输出结果}
  \renewcommand\algorithmcfname{\tongji@name@algorithmname}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 目录样式设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 各级标题格式设置
% 同济的英文摘要以及各章标题都要加粗, 故不需要\ifthenelse{<test>}{<then clause>}{<else clause>}的判断了
\ctexset{%
  chapter={ % 章标题
    afterindent=true,               % afterindent 选项用于设置章节标题后首段的缩进
    pagestyle={tongji@headingmain}, % 这句用来保证章首页的页眉正确
                                    % 注意我们在前面 \mainmatter 时已经定义过 \pagestyle{tongji@headingmain}了, 但这里必须再重新应用一次, 用来保证章首页的页眉正确
    beforeskip={2bp},               % 设置章节标题前的垂直间距
    aftername=\hskip\ccwd,          % 控制章节编号与标题内容之间的距离
                                    % \ccwd 为一个汉字的宽度，在 ctex 宏集中有介绍
    afterskip={18bp},               % 控制章节标题与后面下方之间的距离
    format={\centering\bfseries\tongji@title@font\sanhao[1.8]},
                                    % format 项用于控制章节标题的全局格式, 作用域为章节名字和随后的标题内容
                                    % 可以用于控制章节标题的对齐方式, 整体字体字号等格
    nameformat=\relax,
    numberformat=\relax,
    titleformat=\bfseries,
    lofskip=0pt,                    % 控制插图目录(.lof)中, 章之间的插图标题的距离
    lotskip=0pt,                    % 控制表格目录(.lot)中, 章之间的表格标题的距离
    % loaskip=0pt,
  },
  section={ % 一级节标题
    afterindent=true,
    beforeskip={24bp \@plus 1ex \@minus .2ex},
    afterskip={13bp \@plus .2ex},
    format={\tongji@title@font\xiaosan[1.8]},
	numberformat={\tongji@title@font\sanhao[1]},
  },
  subsection={
    afterindent=true,
    beforeskip={12bp \@plus 1ex \@minus .2ex},
    afterskip={13bp \@plus .2ex},
    format={\tongji@title@font \sihao[1.8]},
    numberformat={\tongji@title@font\xiaosan[1]},
  },
  subsubsection={
    afterindent=true,
    beforeskip={12bp \@plus 1ex \@minus .2ex},
    afterskip={13bp \@plus .2ex},
    format={\tongji@title@font\xiaosi[1.8]},
	numberformat={\tongji@title@font\banxiaosi[1]},
  },
  paragraph/afterindent=true,
  subparagraph/afterindent=true}

% 目录调教:
% \NewDocumentCommand 替代了 \newcommand, 它是 xparse 宏包的主要命令, 可以定义参数个数, 类型等
% 语法: \tongji@chapter{s o m o} 中
%   o 表示可选参数, m 表示强制参数
%   s 表示 optional star, 此时 #1 = 是否带*调用(带*为\BooleanTrue)
%       用于\IfBooleanF, \IfBooleanT, \IfBooleanTF 等
% 解释: 对于's o m o', 如果输入'*[Foo]{Bar}', 那么#1 = \BooleanTrue, #2 = Foo, #3 = Bar, #4 = -NoValue-
% 用法: \cs{tongji@chapter*}\oarg[tocline]\marg{title}\oarg[header]
% tocline 是出现在目录中的条目, 如果为空则此 chapter 不出现在目录中, 如果省略表示目录出现 title
% title   是章标题
% header  是页眉出现的标题, 如果忽略则取 title
\newcounter{tongji@bookmark}
\NewDocumentCommand\tongji@chapter{s o m o}{
  \IfBooleanF{#1}{%如果调用的时候不带*, 那么#1 = \BooleanFalse
    \ClassError{tongjithesis}{You have to use the star form: \string\tongji@chapter*}{}
  }%
  \clearpage 
  \phantomsection % \phantomsection是给 hyperref 用的, 使它能够跳转到正确的页面
  % in other words it puts a hyper marker on the page
  % For example a starred section or chapter added to the TOC would normally refer to the wrong place without \phantomsection
  % \IfValueTF {<argument>} {<true code>} {<false code>}
  \IfValueTF{#2}
  {%若第一个o对应的可选参数没有提供, 那么#2=-NoValue-,此判断为false
    \ifthenelse{\equal{#2}{}}
    {%第二个参数有, 但为空, 此 chapter 不出现在目录中
      \addtocounter{tongji@bookmark}\@ne
      \pdfbookmark[0]{#3}{tongjichapter.\thetongji@bookmark}
      }
    {%第二个参数有, 且不为空, 则将其加入目录
      \addcontentsline{toc}{chapter}{#2}
      % \addcontentsline{file}{sec_unit}{entry}
      % file是文件扩展名: toc (table of contents), lof (list of figures), or lot (list of tables).
      % sec_unit, 对于toc来说就是这些名字: part, chapter, section 等
    }
  }
  {%若没有指定该参数(即#2=-NoValue-), 表示目录出现title
    \addcontentsline{toc}{chapter}{#3}
  }% 
  \chapter*{#3}%
  \IfValueTF{#4}
  {%提供了第四个参数, 即 header
    \ifthenelse{\equal{#4}{}}{\@mkboth{}{}} % 页眉为空
    {% 页眉为 header
      \thispagestyle{fancy}
      \fancyhead{}
      \fancyhead[RO,LE]{#4}
      \fancyfoot{}
      \fancyfoot[C]{\songti\wuhao\thepage}
      \renewcommand{\headrulewidth}{0.4pt}
      \renewcommand{\footrulewidth}{0pt}
    }
    % 注: 此命令等同于 \markboth{left}{right}
    % 也就是定义一个“left-hand heading” 和“righthand heading”
    % 这样, \leftmark 读出来的就是我们设的left, \rightmark 就是我们设的right
    % 通过这种方式, 我们可以很方便地设置页眉
  }
  {% 若未提供 header, 则取 title 为页眉
    \thispagestyle{fancy}
    \fancyhead{}
    \fancyhead[RO,LE]{#3}
    \fancyfoot{}
    \fancyfoot[C]{\songti\wuhao\thepage}
    \renewcommand{\headrulewidth}{0.4pt}
    \renewcommand{\footrulewidth}{0pt}
  }
}

% 目录最多四层, 即: x.x.x.x, 对应的命令和层序号分别是: 
% \cs{chapter}(0), \cs{section}(1), \cs{subsection}(2), \cs{subsubsection}(3)
\setcounter{secnumdepth}{3}
\setcounter{tocdepth}{2}
% The secnumdepth counter controls printing of section numbers
% The setting\setcounter{secnumdepth}{level} suppresses heading numbers at any depth > level,

% 每章标题行前空 6 磅, 后空 0 磅
% 如果目录项的英文要使用 Arial, 那么就加上 \cs{sffamily}
% 章节名中英文用 Arial 字体, 页码仍用 Times
% 减小目录项中的导引小点跟页码之间的留白
% 目录生成命令
\renewcommand\tableofcontents{%
  \tongji@chapter*[]{\contentsname}[\wuhao\songti\tongji@schoolname~\tongji@capply~\contentsname]
  \xiaosi[1.5]\@starttoc{toc}\normalsize\clearpage}


% 调整目录特殊要求, 重定义缩进量
% 研究生学位论文写作指南中规定: 目录中的章标题行居左书写, 一级节标题行缩进 1 个汉字符(2个字符), 二级节标题行缩进 2 个汉字符(4个字符)
\RequirePackage{titletoc}
\contentsmargin{0em}
\titlecontents{chapter}[0em]{\filright}%
    {\xiaosi\songti\thecontentslabel\enspace}%
        {\xiaosi\songti}{\dotfill\contentspage}[\addvspace{0pt}]
\titlecontents{section}[1em]{\addvspace{0pt}}%
    {\xiaosi\songti \thecontentslabel\enspace}%
        {\xiaosi\songti}{\dotfill\contentspage}[\addvspace{0pt}]
\titlecontents{subsection}[2em]{\addvspace{0pt}}%
    {\xiaosi\songti\thecontentslabel\enspace}%
        {\xiaosi\songti}{\dotfill\contentspage}[\addvspace{0pt}]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 论文摘要设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 摘要
% 摘要最好以环境的形式出现 (否则命令的形式会导致开始结束的括号距离太远)
% 因此需要让环境能够自己保存内容留待以后使用
% 使用 \pkg{environ} 的 \cs{Collect@Body} 实现
\newcommand{\tongji@@cabstract}[1]{\long\gdef\tongji@cabstract{#1}}
\newenvironment{cabstract}{\Collect@Body\tongji@@cabstract}{}
\newcommand{\tongji@@eabstract}[1]{\long\gdef\tongji@eabstract{#1}}
\newenvironment{eabstract}{\Collect@Body\tongji@@eabstract}{}
% 不同论文格式关键词之间的分割不太相同
% 用 \cs{ckeywords} 和 \cs{ekeywords} 来收集关键词列表, 然后用本命令来生成符合要求的格式
% \begin{macrocode}
\def\tongji@parse@keywords#1{
  \define@key{tongji}{#1}{\csname #1\endcsname{##1}}
  \expandafter\gdef\csname tongji@#1\endcsname{}
  \expandafter\gdef\csname #1\endcsname##1{
    \@for\reserved@a:=##1\do{
      \expandafter\ifx\csname tongji@#1\endcsname\@empty\else
        \expandafter\g@addto@macro\csname tongji@#1\endcsname{%
          \ignorespaces\csname tongji@#1@separator\endcsname}
      \fi
      \expandafter\expandafter\expandafter\g@addto@macro%
        \expandafter\csname tongji@#1\expandafter\endcsname\expandafter{\reserved@a}}}}
% 利用 \cs{tongji@parse@keywords} 来定义, 内部通过 \cs{tongji@ckeywords} 和
% \cs{tongji@ekeywords} 来引用
\tongji@parse@keywords{ckeywords}
\tongji@parse@keywords{ekeywords}
\newcommand{\tongji@makeabstract}{%
  \cleardoublepage % always openright for Abstract
  \tongji@chapter*[]{\cabstractname}[\wuhao\songti\tongji@schoolname~\tongji@capply~\cabstractname] % no tocline
  \pagenumbering{Roman}
  \tongji@cabstract
  \vskip12bp
  \setbox0=\hbox{{\bfseries\heiti\tongji@ckeywords@title}}
  \noindent\hangindent\wd0\hangafter1
    \box0\tongji@ckeywords
  % \cleardoublepage % always openright for Abstract  
  \tongji@chapter*[]{\eabstractname}[\wuhao\tongji@eschoolname~\quad the degree of Master \quad~\eabstractname] % no tocline
  \tongji@eabstract
  \vskip12bp
  \setbox0=\hbox{{\bfseries Key Words:\enskip}}
  \noindent\hangindent\wd0\hangafter1
    \box0\tongji@ekeywords}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 符号列表设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
% 主要符号对照表  
% 基于清华模板, 利用 \pkg{enumitem} 改造环境定义
\newenvironment{denotation}[1][3.5cm]{
  \tongji@chapter*{\tongji@denotation@name}[\wuhao\songti\tongji@schoolname~\tongji@capply~\tongji@denotation@name]
  \vskip-30bp\xiaosi[1.6]\begin{tongji@denotation}[labelwidth=#1]
}{%
  \end{tongji@denotation}
  \clearpage
}
\newlist{tongji@denotation}{description}{1}
\setlist[tongji@denotation]{%
  nosep,
  font=\normalfont,
  align=left,
  leftmargin=!, % sum of the following 3 lengths
  labelindent=0pt,
  labelwidth=2.5cm,
  labelsep*=0.5cm,
  itemindent=0pt,
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 图表索引设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 定义索引样式
\def\tongji@starttoc#1{% #1: float type, prepend type name in \listof*** entry.
  \let\oldnumberline\numberline
  \def\numberline##1{\oldnumberline{\csname #1name\endcsname\hskip.4em ##1}}
  \@starttoc{\csname ext@#1\endcsname}
  \let\numberline\oldnumberline}
\def\tongji@listof#1{% #1: float type
  \setcounter{tocdepth}{2} % restore tocdepth in case being modified
  \@ifstar
    {%带星的不加入目录, 如\listoftables*
      \tongji@chapter*[]{\csname list#1name\endcsname}[\wuhao\songti\tongji@schoolname~\tongji@capply~\csname list#1name\endcsname]
      \tongji@starttoc{#1}
      \clearpage}
    {%加入目录
      \tongji@chapter*{\csname list#1name\endcsname}[\wuhao\songti\tongji@schoolname~\tongji@capply~\csname list#1name\endcsname]
      \tongji@starttoc{#1}
      \clearpage}
}

% 图片索引
\renewcommand\listoffigures{\tongji@listof{figure}}
\renewcommand*\l@figure{\@dottedtocline{1}{0em}{4em}}
\renewcommand{\@dotsep}{2} %改变索引中点间距
% 表格索引
\let\l@table\l@figure
\renewcommand\listoftables{\tongji@listof{table}}

% 算法索引
\SetAlgoRefRelativeSize{1}
\newcommand{\tongji@algorithm@capsty}{\xiaosi[2]\normalfont}
\AtEndOfPackageFile*{algorithm2e}{
  \SetAlgoCaptionLayout{tongji@algorithm@capsty} % thu@caption@font
  \SetAlCapSty{tongji@algorithm@capsty} % 标题样式
  \SetAlgoCaptionSeparator{\hspace*{1em}} % 分隔符
  \renewcommand\listalgorithmcfname{\tongji@listname@algorithmname}}
\def\ext@algorithmcf{loa}
\let\l@algorithmcf\l@figure
\renewcommand\listofalgorithms{\tongji@listof{algorithmcf}}


% 公式索引
% \LaTeX\ 默认没有公式索引, 此处定义自己的 \cs{listofequations}
% 如果要编号最好用 equation 环境, 否则请手动添加 \cs{equcaption}
% 用法为: \cs{equcaption}\marg{counter}
%   \marg{counter} 指定出现在索引中的编号, 一般取 \cs{theequation}
%   如果你是用 \pkg{amsmath} 的 \cs{tag}, 那么默认是 \cs{tag} 的参数
%   除此之外可能需要你手工指定
\def\ext@equation{loe} % 本命令只是为了生成公式列表, 所以这个 caption 是假的
\def\equcaption#1{%
  \addcontentsline{\ext@equation}{equation}%
                  {\protect\numberline{#1}}}
\let\l@equation\l@figure
\newcommand\listofequations{\tongji@listof{equation}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 致谢声明设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 致谢以及声明
\NewDocumentEnvironment{acknowledgement}{}{%
  \tongji@chapter*[\tongji@ackname]{\tongji@ackname}[\wuhao\songti\tongji@schoolname~\tongji@capply~\tongji@ackname] 
  \fangsong}{\clearpage}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 参考文献设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 兼容参考文献的老命令
\let\inlinecite\parencite
% 全局字体
\renewcommand{\bibfont}{\zihao{5}\songti}%宋体五号
% \setlength{\bibitemsep}{0ex}
\setlength{\bibnamesep}{0ex}
\setlength{\bibinitsep}{0ex}
% 解决参考文献页眉问题(当存在附录时, 参考文献页眉会出问题)
\newcommand\printTJbibliography{
  \ctexset{chapter/pagestyle={tongji@headingref}}
  \pagestyle{tongji@headingref}
  \printbibliography[heading=bibintoc]
  \clearpage
  \ctexset{chapter/pagestyle={tongji@headingmain}}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 附录样式设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\fancypagestyle{tongji@appendix@heading}{%
  \fancyhead{}
  \fancyhead[RO,LE]{\wuhao\songti\tongji@schoolname~\tongji@capply~\appendixname}
  \fancyfoot{}
  \fancyfoot[C]{\songti\wuhao\thepage}
  \renewcommand{\headrulewidth}{0.4pt}
  \renewcommand{\footrulewidth}{0pt}}
\let\tongji@appendix\appendix
\renewenvironment{appendix}{% 
  \ctexset{% 附录仍属于 mainmattertrue 才能正确编号成附录A的形式,
    % 此处的 pagestyle 仍然会沿用我们前面设的 chapter 的 pagestyle, 而我们需要更改附录的页眉, 因此需要重新设置一下页眉
    chapter/pagestyle={tongji@appendix@heading} % 保证首页的页眉正确
    } 
  \pagestyle{tongji@appendix@heading} % 保证附录非首页的页眉正确
  \let\title\tongji@appendix@title
  \tongji@appendix}{%
  \let\title\@gobble \clearpage}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 个人简历设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newenvironment{resume}{%
  \tongji@chapter*{\tongji@resume@title}[\wuhao\songti\tongji@schoolname~\tongji@capply~\tongji@resume@title] 
  \wuhao[1.5] 
  \setlist[enumerate,1]{leftmargin=2em} % 设置enumerate左间隙距离
  }{\clearpage}

\newcommand{\resumeitem}[1]{\vspace{2.5em}{\bfseries\wuhao\heiti\leftline{#1}}\par}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 原创声明设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newenvironment{statement}{%
  \pagestyle{tongji@plain}
  }{\clearpage}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 封面格式设置 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% \parbox[position][height][inner-pos]{width}{text}
% \hb@xt@{width}{text}: 创建指定宽度和内容的水平盒子
\newlength{\tongji@title@width} % 创建宽度变量
\def\tongji@put@title#1{\makebox{\hb@xt@ \tongji@title@width{#1}}} % 创建预设宽度变量和指定内容的盒子

\newcommand{\chicover} % 中文封面
{
  \begin{center}
    \parbox[t][1.8cm][t]{\textwidth}{
      \hspace*{11.2cm}
      \iftongji@secret{\sanhao\tongji@secret@title}
      \else\rule{1cm}{0cm} \fi % 是否显示密级
      \\[0.1cm]
      \iftongji@electronic{{\kaishu\xiaosi\bfseries\itshape\tongji@thesistype (打印时删除)}}
      \else\rule{1cm}{0cm} \fi % 是否显示打印时删除
    }
    \\[-.9cm]
    \parbox[t][1.8cm][t]{\textwidth}{
      \centering\hspace*{.3cm}
      \includegraphics[width=10cm]{tongji-whole-logo.pdf}
    } % logo
    \\[-.6cm] 
    
    \parbox[t][5cm][t]{\paperwidth-7cm}{
      \begin{center}
        \erhao[1]{{\bfseries\lishu\tongji@capply}} \par
        \iftongji@academic{\sihao[1]{{\bfseries\lishu(学术学位)}}}
        \else \iftongji@profession{\sihao[1]{{\bfseries\lishu(专业学位)}}}
        \else \iftongji@equaleducation {\sihao[1]{{\bfseries\lishu(同等学力)}}}
        \fi \fi \fi \par

        \parbox[t]{\paperwidth-7cm}{\begin{center}\zihao{-4}\linespread{1.0}\selectfont
          \erhao[2]{\bfseries\heiti\tongji@ctitle} % title
        \end{center}}
        \par\vskip -0.3cm

        \parbox[t]{\paperwidth-7cm}{\begin{center}\zihao{-4}\linespread{1.3}\selectfont
          \ifx\cfunds\@empty\else\tongji@cfunds\fi
        \end{center}}
      \end{center}
    }
    \par\vskip 3cm

    \hspace*{1.2cm}
    \parbox[t][11cm][t]{\textwidth}{
      {
        \fangsong\sanhao[1.5]        
        \begin{center}
          \setlength{\extrarowheight}{4pt}          
          \iftongji@profession % 专业学位
              \setlength{\tongji@title@width}{7em}
              \ifxetex \begin{tabular}{p{\tongji@title@width}@{}c@{\extracolsep{8pt}}p{7cm}l}
              \else \begin{tabular}{p{\tongji@title@width}c@{\extracolsep{8pt}}p{7cm}l} \fi
              \tongji@put@title{\tongji@cauthortitle}                & \tongji@title@sep & \tongji@cauthor            \\
              \tongji@put@title{\tongji@cstudentnumbertitle}         & \tongji@title@sep & \tongji@studentnumber      \\
              \tongji@put@title{\tongji@cdepartmenttitle}            & \tongji@title@sep & \tongji@cdepartment        \\
              \tongji@put@title{\tongji@csubjectcategorytitle}       & \tongji@title@sep & \tongji@csubjectcategory   \\
              \tongji@put@title{\tongji@cmajorfirsttitleprofession}  & \tongji@title@sep & \tongji@cmajorfirst        \\
              \tongji@put@title{\tongji@cmajorsecondtitleprofession} & \tongji@title@sep & \tongji@cmajorsecond       \\ 
              \tongji@put@title{\tongji@cresearchfieldtitle}         & \tongji@title@sep & \tongji@cresearchfield     \\
              \tongji@put@title{\tongji@csupervisortitle}            & \tongji@title@sep & \tongji@csupervisor        \\
              \ifx\tongji@cassosupervisor\@empty\else
                \tongji@put@title{\tongji@cassosupertitleprofession} & \tongji@title@sep & \tongji@cassosupervisor    \\
              \fi
              \ifx\tongji@cjointinstitution\@empty\else
                  \tongji@put@title{\tongji@cjointinstitutiontitle}  & \tongji@title@sep & \tongji@cjointinstitution  \\
              \fi
          \else % 学术学位
              \ifx\tongji@cassosupervisor\@empty \setlength{\tongji@title@width}{5em}
              \else \setlength{\tongji@title@width}{6em} \fi
              \ifxetex \begin{tabular}{p{\tongji@title@width}@{}c@{\extracolsep{8pt}}p{7cm}l}
              \else \begin{tabular}{p{\tongji@title@width}c@{\extracolsep{8pt}}p{7cm}l} \fi
              \tongji@put@title{\tongji@cauthortitle}           & \tongji@title@sep    & \tongji@cauthor              \\
              \tongji@put@title{\tongji@cstudentnumbertitle}    & \tongji@title@sep    & \tongji@studentnumber        \\
              \tongji@put@title{\tongji@cdepartmenttitle}       & \tongji@title@sep    & \tongji@cdepartment          \\
              \tongji@put@title{\tongji@csubjectcategorytitle}  & \tongji@title@sep    & \tongji@csubjectcategory     \\
              \tongji@put@title{\tongji@cmajorfirsttitle}       & \tongji@title@sep    & \tongji@cmajorfirst          \\
              \tongji@put@title{\tongji@cmajorsecondtitle}      & \tongji@title@sep    & \tongji@cmajorsecond         \\
              \tongji@put@title{\tongji@cresearchfieldtitle}    & \tongji@title@sep    & \tongji@cresearchfield       \\
              \tongji@put@title{\tongji@csupervisortitle}       & \tongji@title@sep    & \tongji@csupervisor          \\
              \ifx\tongji@cassosupervisor\@empty\else
                  \tongji@put@title{\tongji@cassosupertitle} & \tongji@title@sep & \tongji@cassosupervisor            \\
              \fi
              \ifx\tongji@cjointinstitution\@empty\else
                  \tongji@put@title{\tongji@cjointinstitutiontitle} & \tongji@title@sep & \tongji@cjointinstitution   \\
              \fi
        \fi
        \end{tabular}
      \end{center}}
    }

    \begin{center}
      {\sanhao\songti\tongji@cdate}
    \end{center}
  \end{center}
} % end of titlepage

% 英文封面
\newcommand{\engcover}
{%
  \begin{center}
      \vspace*{0.8cm}
      \parbox[t][1.8cm][t]{\textwidth}{
        \centering\hspace*{.3cm}
       \includegraphics[width=10cm]{tongji-whole-logo.pdf}
      } % logo
      \\[-.6cm]
      
      \parbox[t][8cm][t]{\paperwidth-6cm}{
        \begin{center}
          \iftongji@doctor \sihao[1.3]{\tongji@eapplydoctor}
          \else \iftongji@master \sihao[1.3]{\tongji@eapplymaster}
          \fi \fi \par\vskip 1.4cm

          \xiaoer[1.5]{\bfseries\sffamily\tongji@etitle}
          \par% \vskip 14pt

          \ifx\efunds\@empty\else\xiaosi[1.3]{\tongji@efunds}\fi
        \end{center}
      }

      \hspace*{-1.2cm}
      \parbox[t][11cm][t]{0.80\textwidth}{
        \sanhao[1.5] % 1.0 for smaller fonts
        \begin{center}
          \iftongji@profession % 专业学位
              \setlength{\tongji@title@width}{6em}
              \begin{tabular}{p{12cm}}
                \tongji@eauthortitle               \tongji@title@esep \tongji@eauthor            \\
                \tongji@estudentnumbertitle        \tongji@title@esep \tongji@studentnumber      \\
                \tongji@edepartmenttitle           \tongji@title@esep \tongji@edepartment        \\
                \tongji@esubjectcategorytitle      \tongji@title@esep \tongji@esubjectcategory   \\
                \tongji@emajorfirsttitleprofession \tongji@title@esep \tongji@emajorfirst        \\
                \tongji@emajorsecondtitleprofession\tongji@title@esep \tongji@emajorsecond       \\ 
                \tongji@eresearchfieldtitle        \tongji@title@esep \tongji@eresearchfield     \\
                \tongji@esupervisortitle           \tongji@title@esep \tongji@esupervisor        \\
                \ifx\tongji@eassosupervisor\@empty\else
                  \tongji@eassosupertitleprofession\tongji@title@esep \tongji@eassosupervisor    \\
                \fi
                \ifx\tongji@ejointinstitution\@empty\else
                    \tongji@ejointinstitutiontitle \tongji@title@esep \tongji@ejointinstitution  \\
                \fi
          \else % 学术学位
            \ifx\tongji@cassosupervisor\@empty \setlength{\tongji@title@width}{4em}
            \else \setlength{\tongji@title@width}{5em} \fi
            \begin{tabular}{p{12cm}}
                \tongji@eauthortitle               \tongji@title@esep \tongji@eauthor            \\
                \tongji@estudentnumbertitle        \tongji@title@esep \tongji@studentnumber      \\
                \tongji@edepartmenttitle           \tongji@title@esep \tongji@edepartment        \\
                \tongji@esubjectcategorytitle      \tongji@title@esep \tongji@esubjectcategory   \\
                \tongji@emajorfirsttitle           \tongji@title@esep \tongji@emajorfirst        \\
                \tongji@emajorsecondtitle          \tongji@title@esep \tongji@emajorsecond       \\
                \tongji@eresearchfieldtitle        \tongji@title@esep \tongji@eresearchfield     \\
                \tongji@esupervisortitle           \tongji@title@esep \tongji@esupervisor        \\
                \ifx\tongji@eassosupervisor\@empty\else
                    \tongji@eassosupertitle        \tongji@title@esep \tongji@eassosupervisor    \\
                \fi
                \ifx\tongji@ejointinstitution\@empty\else
                    \tongji@ejointinstitutiontitle \tongji@title@esep \tongji@ejointinstitution  \\
                \fi
          \fi
          \end{tabular}
        \end{center}
      }
      
      \begin{center}
        \sanhao\tongji@edate
      \end{center}
  \end{center}
} % end of english cover

% \newcommand\tongji@underline[2][6em]{\hskip1pt\underline{\hb@xt@ #1{\hss#2\hss}}\hskip3pt}

% 生成封面总命令
\newcommand{\makecover}{
  \phantomsection
  \pdfbookmark[-1]{\tongji@ctitle}{ctitle}
  \normalsize%
  \begin{titlepage}
    \chicover
    \cleardoublepage
    \engcover
    \cleardoublepage
  \end{titlepage}
  \normalsize
  \tongji@makeabstract
  \let\@tabular\tongji@tabular}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 书脊设置(失效) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 书脊
% 单独使用书脊命令会在新的一页产生竖排书脊
\NewDocumentCommand{\shuji}{O{\tongji@ctitle} O{\tongji@cauthor}}{%
  \newpage\thispagestyle{empty}%
  \fangsong\ifxetex\addCJKfontfeatures*{RawFeature={vertical:}}\fi
  \xiaosan\ziju{0.4}%
  \noindent\hfill\rotatebox[origin=lt]{-90}{\makebox[\textheight]{#1\hfill#2}}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 自定义指令 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 生成新的 mathversion
\newcounter{mathversioncount} % 定义计数器
% 解决报错 Too many math alphabets used in version normal: 每章一个 mathversion
\newcommand{\wyqymathversion}[1]{
  \loop % 循环生成
    \stepcounter{mathversioncount}
    \expandafter\def\csname wyqymath\arabic{mathversioncount}\endcsname{}
    \expandafter\DeclareMathVersion\expandafter{\csname wyqymath\arabic{mathversioncount}\endcsname}
  \ifnum\value{mathversioncount}<#1\repeat
  \setcounter{mathversioncount}{0} % 重置计数器
}
% 插入文件, 同时应用环境
\newcommand{\wyqyinputfile}[2][\relax]{% 第一个参数为环境名称(可选), 第二个参数为插入文件名称(强制)
  \stepcounter{mathversioncount}
  \ifx#1\relax % 没有提供可选参数
    {\expandafter\mathversion\expandafter{\csname wyqymath\arabic{mathversioncount}\endcsname}}
      \input{data/#2} \mathversion{normal}
  \else % 提供了可选参数
    {\expandafter\mathversion\expandafter{\csname wyqymath\arabic{mathversioncount}\endcsname}}
      \begin{#1} \input{data/#2} \end{#1}
      \mathversion{normal}
  \fi
}


% 后处理: 在标题中含有 \\ 的情况下, 删除 \\ xstringmid@chaptermark
\newcounter{substitutecount} % 定义计数器
\setcounter{substitutecount}{0} % 重置计数器
% 预定义格式参考
\def\xstringintern@pattern@a{ \\ }
\def\xstringintern@pattern@b{ \\}
\def\xstringintern@pattern@c{\\ }
\def\xstringintern@pattern@d{\\}
% 原文本为命令式, 每次调用都会生成新的变量名
\newcommand{\wyqydeletelinebreakcmd}[2]{% 第一个参数为原文本命令名称, 第二个参数为新文本命令名称
  \stepcounter{substitutecount}
  \expandafter\StrSubstitute\expandafter{\csname#1\expandafter\endcsname\expandafter}\expandafter{\csname xstringintern@pattern@a\expandafter\endcsname\expandafter}\expandafter{\expandafter}\expandafter[\csname xstringintern@delbreak@\arabic{substitutecount}\endcsname]
  \stepcounter{substitutecount}
  \expandafter\StrSubstitute\expandafter{\csname xstringintern@delbreak@\the\numexpr\arabic{substitutecount}-1\relax\expandafter\endcsname\expandafter}\expandafter{\csname xstringintern@pattern@b\expandafter\endcsname\expandafter}\expandafter{\expandafter}\expandafter[\csname xstringintern@delbreak@\arabic{substitutecount}\endcsname]
  \stepcounter{substitutecount}
  \expandafter\StrSubstitute\expandafter{\csname xstringintern@delbreak@\the\numexpr\arabic{substitutecount}-1\relax\expandafter\endcsname\expandafter}\expandafter{\csname xstringintern@pattern@c\expandafter\endcsname\expandafter}\expandafter{\expandafter}\expandafter[\csname xstringintern@delbreak@\arabic{substitutecount}\endcsname]
  \stepcounter{substitutecount}
  \expandafter\StrSubstitute\expandafter{\csname xstringintern@delbreak@\the\numexpr\arabic{substitutecount}-1\relax\expandafter\endcsname\expandafter}\expandafter{\csname xstringintern@pattern@d\expandafter\endcsname\expandafter}\expandafter{\expandafter}\expandafter[\csname xstringintern@delbreak@\arabic{substitutecount}\endcsname]
  \expandafter\gdef\csname#2\expandafter\endcsname\expandafter{\csname xstringintern@delbreak@\arabic{substitutecount}\endcsname}
}
\newcommand{\wyqydeletelinebreaktxt}[2]{% 第一个参数为原文本内容, 第二个参数为新文本命令名称
   \def\xstringintern@args{#1}
   \wyqydeletelinebreakcmd{xstringintern@args}{#2}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 结束 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 在模板文档结束时即装入配置文件, 这样用户就能在导言区进行相应的修改
\AtEndOfClass{\input{tongjithesis.cfg}}
\AtEndOfClass{\sloppy}

\endinput
%% End of file `tongjithesis.cls'.
