package com.phm.rule.expression;

import java.util.ArrayList;
import java.util.List;

/**
 * 给前端画分组清单和梯形图用的展示树。命名组单独成 named 节点，子树在 child 上。
 */
public class DisplayNode {

    /** and / or / leaf / named */
    public String type;
    /** 故障组合式中的 A1…，命名组内部叶子为空 */
    public String alias;
    /** 原子或命名组编号 */
    public String code;
    /** 命名组名称 */
    public String name;
    /** 中文说法 */
    public String text;
    /** 该叶子的零 JSON 片段；命名组为展开式 */
    public String expr;
    public List<DisplayNode> children = new ArrayList<DisplayNode>();
    /** 命名组展开后的子树 */
    public DisplayNode child;
}
