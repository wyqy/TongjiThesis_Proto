# TongjiThesis
## 总览
WYQY的硕士毕业论文 by 同济大学硕博士论文LaTeX模板

本次修改的发起者：
* [WYQY](https://github.com/wyqy)

特别致谢：
* [hushidong/biblatex-gb7714-2015](https://github.com/hushidong/biblatex-gb7714-2015) 提供的参考文献宏包
* [TongjiThesis](https://github.com/marquistj13/TongjiThesis) 给出的初始Tongji模板

历史贡献者列表:[请点击这里](https://github.com/marquistj13/TongjiThesis/graphs/contributors)

主要参考资料：
* [ThuThesis](https://github.com/tuna/thuthesis);
* [TongjiThesis @ Tongji LUG, 2014](https://sourceforge.net/projects/tongjithesis/);
* [TongjiThesis @ marquistj13, CNchence, Wenda, 2020](https://github.com/marquistj13/TongjiThesis);
* ``Copilot`` \& ``texdoc`` \& ``tex.stackexchange.com``.

## 版本说明
适配了 VSCode + TeXLive 2023+ 平台

### 安装
1. (必需) 安装 [Texlive](https://mirrors.tuna.tsinghua.edu.cn/ctan/systems/texlive/Images/);
1. (必需) 安装 [VSCode](https://code.visualstudio.com/);
1. (必需) 安装 ``fonts`` 文件夹下的字体;
1. (可选) 安装 [SumatraPDF](https://www.sumatrapdfreader.org/free-pdf-reader), 请参阅 [Zhihu](https://zhuanlan.zhihu.com/p/95330916) 配置相应文件;
1. 开始使用.

### 使用
1. 切记根据 ``wyqyinputfile`` 命令的使用次数修改 ``\wyqymathversion`` 的参数 (位于 thesis.tex 文件的第14行).

### 编译过程中出现未知的奇怪的错误怎么办
若碰到奇怪的错误, 最好的方法就是： __清除所有临时文件, 重新编译__ 

### 关于 author year 的引用
本模板严格遵循国标, 如对此有疑问, 请通过借酒消愁等方式解决

### 关于参考文献bib的生成
推荐使用 Zotero 进行文献管理和 bib 生成, 其中 bib 的生成推荐使用 Zotero 的 `Better Bib(La)TeX` 插件
如果你也用zotero管理文献的话, 可以参考 [这里](https://marquistj13.github.io/MyBlog/2018/05/zotero-export/#%E8%B0%83%E6%95%99better-bibtex-%E6%8F%92%E4%BB%B6%E7%94%9F%E6%88%90%E7%9A%84bib%E6%96%87%E4%BB%B6%E7%9A%84field) 的文献库导出设置, 这样就可以方便地将bib文件的language域删掉或另行处理, （很久以前需要删掉这个language域, 现在不确定是否需要删, 没时间测试了, 诸位自行定夺）
