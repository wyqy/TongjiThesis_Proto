# TongjiThesis (最后更新: 2025/03/06)
## 1. 总览
同济大学硕博士论文LaTeX模板修订版, 绝赞更新中!

本次修改的发起者：
* [WYQY](https://github.com/wyqy)

特别致谢：
* [hushidong/biblatex-gb7714-2015](https://github.com/hushidong/biblatex-gb7714-2015) 提供的参考文献宏包
* [TongjiThesis](https://github.com/marquistj13/TongjiThesis) 给出的初始Tongji模板

历史贡献者列表: [请点击这里](https://github.com/marquistj13/TongjiThesis/graphs/contributors)

主要参考资料：
* [ThuThesis](https://github.com/tuna/thuthesis), [ustcthesis](https://github.com/ustctug/ustcthesis);
* [TongjiThesis @ Tongji LUG, 2014](https://sourceforge.net/projects/tongjithesis/);
* [TongjiThesis @ marquistj13, CNchence, Wenda, 2020](https://github.com/marquistj13/TongjiThesis);
* ``Copilot`` \& ``texdoc`` \& ``tex.stackexchange.com``.

免责声明:
* 本模板附带的字体仅用于`同济大学硕博士论文LaTeX模板`效果展示和`同济大学学位论文`撰写, 版权归属原作者所有, 若需使用请自行获取字体授权

## 2. 更新历史

- _(20250305) ver 1.9.0_ 
  - 更新标题和页眉的字体, 符合最新标准
  - 将 `\mathcal` 字体恢复为默认, 便于使用 (感谢[@ssyuwang](https://github.com/ssyuwang)提醒);
  - 删除过时的代码和宏包, 添加了一些宏包使用说明, 便于自行修改;
  - **兼容性更改: 该版本将模板的 `cyrillic` 选项更新为 `encoding`, 需要使用 `fontenc` 宏包的高级用户请参照说明修改**;
  - **兼容性更改: 该版本将所有非必需宏包的调用移动到了 `tongjiutils.sty`, 需要使用相关宏包的代码请对照更新`tongjiutils.sty`**.

## 3. 运行环境

> #### ※ TeXLive 2024 完整安装 &nbsp;&nbsp;(tested on Windows 11 / Ubuntu 24.04);
> #### ※ MacTeX  2024 完整安装 &nbsp;&nbsp;(tested on macOS 10.15);
> #### ※ 其它基于 TeXLive 2024 的在线编译环境 &nbsp;&nbsp;(tested on Overleaf).

注意:

- 本模板 __仅支持 XeLaTeX__, 如报错请首先检查编译命令是否正确;
- 本模板附带了所需的中英文字体, 因而项目体积较大, 上传至在线编译环境时可删除 `.git` 目录减小体积
- 本模板附带的字体 __不需要__ 安装到系统中, 模板会自行调用.


## 4. 使用方法

### 4.1. 目录结构

| 名称 | 解释 |
| ---- | ---- |
| thesis.tex | 主文档 |
| ctex-fontset-tongji.def, <br>tongjithesis.cfg, <br>tongjithesis.cls | 必需模板文件 |
| tongjiutils.sty | 可选模板文件 <br>如不需要可删除, 并注释掉  [thesis.tex @ L22](https://github.com/wyqy/TongjiThesis_Proto/blob/main/thesis.tex#L22 ) |
| `data` 目录 | 存放各章对应的 .tex 文件 |
| `figures` 目录 | 存放模板示例用到的图片文件 |
| `fonts` 目录 | 存放模板用到的字体 ( 不需要手动安装 ) |
| `ref` 目录 | 存放参考文献 refs.bib |
| `.github ` 和 `.vscode` 目录 | 存放 GitHub Action 和 VSCode 配置文件, <br>如不使用可删除 |

### 4.3. 使用步骤

> #### ※ 请使用 XeLaTeX 编译 thesis.tex
> &nbsp;&nbsp;&nbsp;&nbsp;建议使用 VSCode + SumatraPDF, 可调用模板提供的配置文件直接编译和预览
> #### ※ 需要使用 ``\tongjiinputfile`` 命令导入 `data` 目录下的 .tex 文件 ( 用法详见 thesis.tex )
> #### ※ 需要提前根据 ``\tongjiinputfile`` 命令的使用次数修改 ``\tongjimathversion`` 的参数 ( 位于 [thesis.tex @ L21](https://github.com/wyqy/TongjiThesis_Proto/blob/main/thesis.tex#L21) )
> #### ※ 如果需要额外引入宏包和导言区命令, 请将其写入到 ``tongjiutils.sty`` 文件中
> &nbsp;&nbsp;&nbsp;&nbsp;该文件仅用于示例文件的编译, 如不需要对应宏包/功能, 可自信修改或直接删除
> #### ※ 本模板已根据最新的 ``写作示例`` 修订了页眉格式 ( 感谢 [@colderwater666](https://github.com/colderwater666) )
> &nbsp;&nbsp;&nbsp;&nbsp;如果要返回到旧版, 请在第一行的参数部分设置 ``newstyle=false`` 还原
> #### ※ 本模板配置了 GitHub Action 功能, 如果上传到 GitHub, 可实现自动编译并发布 Release ( [@xu-cheng/latex-action](https://www.github.com/xu-cheng/latex-action/tree/v3/) )
> &nbsp;&nbsp;&nbsp;&nbsp;GitHub Actions 功能对于私有仓库 __不免费__, 若不需要该功能, 请删去 build-release.yml 文件中的 ``on`` 触发器 (位于 [build-release.yml @ L7-L13](https://github.com/wyqy/TongjiThesis_Proto/blob/main/.github/workflows/build-release.yml#L7-L13))



## 5. F&Q

### 编译过程中出现未知的奇怪的错误怎么办
若碰到奇怪的错误, 最好的方法就是： __清除所有临时文件, 重新编译__
### 编译选项在哪里 / 如何自定义编译选项 (如修改输出目录)
本模板默认使用 latexmk + xelatex 编译, 如果需要使用其他 LaTeX 编辑器 / 自定义编译选项 (如修改输出目录), 可查找项目中的 setting.json 文件 (用于 VSCode) 或 build-release.yml 文件 (用于 GitHub Actions)

### 关于 author year 的引用
本模板使用经过广泛验证和良好维护的引用样式包 [biblatex-gb7714-2015](https://github.com/hushidong/biblatex-gb7714-2015) 生成引用

如有问题, 可尝试使用 tlmgr 包管理器安装该宏包的不同版本, 或者~~自行修补代码-~~

### 关于参考文献 bib 的生成
推荐使用 Zotero 进行文献管理和 bib 生成, 其中 bib 的生成推荐使用 Zotero 的 `Better Bib(La)TeX` 插件
如果你也用 Zotero 管理文献的话, 可以参考 [这里](https://marquistj13.github.io/MyBlog/2018/05/zotero-export/#%E8%B0%83%E6%95%99better-bibtex-%E6%8F%92%E4%BB%B6%E7%94%9F%E6%88%90%E7%9A%84bib%E6%96%87%E4%BB%B6%E7%9A%84field) 的文献库导出设置, 这样就可以方便地将 bib 文件的 language 域删掉或另行处理, 
