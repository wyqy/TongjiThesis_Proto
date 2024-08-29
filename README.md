# TongjiThesis - 2024
## 总览
同济大学硕博士论文LaTeX模板 - 2024 年修订版, 绝赞更新中!

本次修改的发起者：
* [WYQY](https://github.com/wyqy)

特别致谢：
* [hushidong/biblatex-gb7714-2015](https://github.com/hushidong/biblatex-gb7714-2015) 提供的参考文献宏包
* [TongjiThesis](https://github.com/marquistj13/TongjiThesis) 给出的初始Tongji模板

历史贡献者列表:[请点击这里](https://github.com/marquistj13/TongjiThesis/graphs/contributors)

主要参考资料：
* [ThuThesis](https://github.com/tuna/thuthesis), [ustcthesis](https://github.com/ustctug/ustcthesis);
* [TongjiThesis @ Tongji LUG, 2014](https://sourceforge.net/projects/tongjithesis/);
* [TongjiThesis @ marquistj13, CNchence, Wenda, 2020](https://github.com/marquistj13/TongjiThesis);
* ``Copilot`` \& ``texdoc`` \& ``tex.stackexchange.com``.

## 版本说明
基于 __TeXLive__ 编写, 版本要求为 __2023 及以上__, 同时要求使用 __XeLaTeX__ 编译
推荐使用 VSCode + SumatraPDF 编辑

### 安装
1. (必需) 安装 [Texlive](https://mirrors.tuna.tsinghua.edu.cn/ctan/systems/texlive/Images/);
1. (建议) 安装 [VSCode](https://code.visualstudio.com/) 和 [latex-workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) 插件
1. (建议) 安装 [SumatraPDF](https://www.sumatrapdfreader.org/free-pdf-reader), 请参阅 [Zhihu](https://zhuanlan.zhihu.com/p/95330916) 配置相应文件;
1. 开始使用.

### 使用
1. 需要提前根据 ``wyqyinputfile`` 命令的使用次数修改 ``\wyqymathversion`` 的参数 (位于 [thesis.tex @ L16](https://github.com/wyqy/TongjiThesis_Proto/blob/main/thesis.tex#L16)).
1. 已根据最新的 ``写作示例`` 修订了页眉格式 (感谢 [@colderwater666](https://github.com/colderwater666)); 如果要返回到旧版, 请参照 [thesis.tex @ L9](https://github.com/wyqy/TongjiThesis_Proto/blob/main/thesis.tex#L9) 的说明, 通过设置 ``newstyle=false`` 还原

### 发布
1. 本模板使用 GitHub Actions 测试代码正确性, 如果编译成功, 则可在 Release 下载编译好的 pdf 文件和相应的源代码
1. 注意:
   - 编译环境默认为 Ubuntu + TeXLive 2024 [(@xu-cheng/latex-action)](https://www.github.com/xu-cheng/latex-action/tree/v3/), 尽管进行了仔细检查, 但不同平台仍有可能出现内容的不一致问题, 因此请仔细检查编译生成的 pdf 文件
   - GitHub Actions 功能对于私有仓库 __不免费__, 本仓库默认配置为对于 __每一个 main 分支上的提交均运行一次编译__, 若不需要该功能, 请删去 build-release.yml 文件中的 ``workflow_dispatch: {}`` (位于 [build-release.yml @ L13](https://github.com/wyqy/TongjiThesis_Proto/blob/main/.github/workflows/build-release.yml#L13))

## F&Q
### 编译过程中出现未知的奇怪的错误怎么办
若碰到奇怪的错误, 最好的方法就是： __清除所有临时文件, 重新编译__
### 编译选项在哪里 / 如何自定义编译选项 (如修改输出目录)
本模板默认使用 latexmk + xelatex 编译, 如果需要使用其他 LaTeX 编辑器 / 自定义编译选项 (如修改输出目录), 可查找项目中的 setting.json 文件 (用于 VSCode) 或 build-release.yml 文件 (用于 GitHub Actions)

### 关于 author year 的引用
本模板使用经过广泛验证和良好维护的引用样式包 [biblatex-gb7714-2015](https://github.com/hushidong/biblatex-gb7714-2015) 生成引用

如有问题, 可尝试使用 tlmgr 包管理器安装该宏包的不同版本, 或者~~自行修补代码-~~

### 关于参考文献bib的生成
推荐使用 Zotero 进行文献管理和 bib 生成, 其中 bib 的生成推荐使用 Zotero 的 `Better Bib(La)TeX` 插件
如果你也用zotero管理文献的话, 可以参考 [这里](https://marquistj13.github.io/MyBlog/2018/05/zotero-export/#%E8%B0%83%E6%95%99better-bibtex-%E6%8F%92%E4%BB%B6%E7%94%9F%E6%88%90%E7%9A%84bib%E6%96%87%E4%BB%B6%E7%9A%84field) 的文献库导出设置, 这样就可以方便地将bib文件的language域删掉或另行处理, （很久以前需要删掉这个language域, 现在不确定是否需要删, 没时间测试了, 诸位自行定夺）
