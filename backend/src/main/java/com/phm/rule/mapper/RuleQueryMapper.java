package com.phm.rule.mapper;

import com.phm.rule.entity.FaultRule;
import com.phm.rule.entity.PreFilterRule;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

/**
 * 不适合用逻辑删除拦截的 SQL：含已删除行的查找、物理删除、以及与样例查询一致的前置规则加载。
 * 字符串拼接用 ||。金仓 Oracle 模式下 CONCAT 会把无类型字面量解析成 sys.concat，报函数不存在；|| 在 PostgreSQL 和该模式都能用。
 */
@Mapper
public interface RuleQueryMapper {

    /**
     * 按车型、来源、故障代码查找，包含已逻辑删除的行，便于同键恢复。
     *
     * @param cx   车型
     * @param ly   来源
     * @param gzdm 故障代码
     * @return 行，没有则 null
     */
    @Select("SELECT * FROM t_phm_fault_rule WHERE cx = #{cx} AND ly = #{ly} AND gzdm = #{gzdm}")
    FaultRule selectFaultAny(@Param("cx") String cx, @Param("ly") String ly, @Param("gzdm") String gzdm);

    /**
     * 把逻辑删除的故障规则恢复为正常。唯一键不允许另插一行。
     *
     * @param id 主键
     * @return 影响行数
     */
    @Update("UPDATE t_phm_fault_rule SET del_flag = 0 WHERE id = #{id}")
    int restoreFault(@Param("id") Long id);

    /**
     * 诊断加载用的前置规则：启用、车型与来源命中、且没有被该故障豁免。
     * 排序与 db/03_sample_queries.sql 一致：执行时机降序，优先级升序。
     *
     * @param faultId 故障规则主键
     * @return 应继承的前置规则
     */
    @Select("SELECT p.* FROM t_phm_pre_filter_rule p, t_phm_fault_rule f "
            + "WHERE f.id = #{faultId} AND f.del_flag = 0 AND p.is_enabled = 1 AND p.del_flag = 0 "
            + "AND (p.scope_cx = 'ALL' OR (',' || p.scope_cx || ',') LIKE ('%,' || f.cx || ',%')) "
            + "AND (p.scope_ly = 'ALL' OR p.scope_ly = f.ly) "
            + "AND NOT EXISTS (SELECT 1 FROM t_phm_fault_pre_skip k "
            + "WHERE k.fault_rule_id = f.id AND k.filter_id = p.id AND k.del_flag = 0) "
            + "ORDER BY p.exec_timing DESC, p.priority")
    List<PreFilterRule> selectInheritedFilters(@Param("faultId") Long faultId);

    /**
     * @return 全部原子编号，含已删除，避免编号重复
     */
    @Select("SELECT atom_code FROM t_phm_rule_atom")
    List<String> allAtomCodes();

    /**
     * @return 全部命名组编号，含已删除
     */
    @Select("SELECT group_code FROM t_phm_rule_group")
    List<String> allGroupCodes();

    /**
     * @return 全部前置规则编码，含已删除
     */
    @Select("SELECT filter_code FROM t_phm_pre_filter_rule")
    List<String> allFilterCodes();

    /**
     * @return 全部流程编码，含已删除
     */
    @Select("SELECT flow_code FROM t_phm_dispose_flow")
    List<String> allFlowCodes();

    /**
     * 组名全局唯一，已删除的行也占着唯一约束。
     *
     * @param name 名称
     * @param id   排除的主键，新建传 0
     * @return 冲突条数
     */
    @Select("SELECT COUNT(*) FROM t_phm_rule_group WHERE group_name = #{name} AND id <> #{id}")
    int countGroupName(@Param("name") String name, @Param("id") long id);

    /**
     * 物理删除故障的引入清单，保存时整体重建。
     *
     * @param faultId 故障主键
     * @return 行数
     */
    @Delete("DELETE FROM t_phm_fault_rule_ref WHERE fault_rule_id = #{faultId}")
    int deleteRefs(@Param("faultId") Long faultId);

    /**
     * 物理删除故障的豁免记录。
     *
     * @param faultId 故障主键
     * @return 行数
     */
    @Delete("DELETE FROM t_phm_fault_pre_skip WHERE fault_rule_id = #{faultId}")
    int deleteSkips(@Param("faultId") Long faultId);

    /**
     * 删除前置规则时清掉豁免，避免悬挂引用。
     *
     * @param filterId 前置规则主键
     * @return 行数
     */
    @Delete("DELETE FROM t_phm_fault_pre_skip WHERE filter_id = #{filterId}")
    int deleteSkipsByFilter(@Param("filterId") Long filterId);

    /**
     * 物理删除命名组的成员，保存时按组合式重建。
     *
     * @param groupId 组主键
     * @return 行数
     */
    @Delete("DELETE FROM t_phm_rule_group_item WHERE group_id = #{groupId}")
    int deleteGroupItems(@Param("groupId") Long groupId);

    /**
     * 解绑时物理删除绑定行，故障才能重新绑定。
     *
     * @param faultId 故障主键
     * @return 行数
     */
    @Delete("DELETE FROM t_phm_dispose_flow_bind WHERE fault_rule_id = #{faultId}")
    int deleteBindByFault(@Param("faultId") Long faultId);

    /**
     * @param flowId 流程主键
     * @return 行数
     */
    @Delete("DELETE FROM t_phm_dispose_flow_bind WHERE flow_id = #{flowId}")
    int deleteBindsByFlow(@Param("flowId") Long flowId);

    /**
     * 先断开指向该步骤的出口，再删步骤自己的子表。
     *
     * @param stepId 步骤主键
     * @return 行数
     */
    @Update("UPDATE t_phm_dispose_branch SET next_step_id = NULL WHERE next_step_id = #{stepId}")
    int clearBranchTarget(@Param("stepId") Long stepId);

    /**
     * @param stepId 步骤主键
     * @return 行数
     */
    @Delete("DELETE FROM t_phm_dispose_branch WHERE step_id = #{stepId}")
    int deleteBranches(@Param("stepId") Long stepId);

    /**
     * @param stepId 步骤主键
     * @return 行数
     */
    @Delete("DELETE FROM t_phm_dispose_confirm WHERE step_id = #{stepId}")
    int deleteConfirms(@Param("stepId") Long stepId);

    /**
     * @param stepId 步骤主键
     * @return 行数
     */
    @Delete("DELETE FROM t_phm_dispose_card WHERE step_id = #{stepId}")
    int deleteCards(@Param("stepId") Long stepId);

    /**
     * @param stepId 步骤主键
     * @return 行数
     */
    @Delete("DELETE FROM t_phm_dispose_step WHERE id = #{stepId}")
    int deleteStep(@Param("stepId") Long stepId);

    /**
     * 调整顺序前把序号挪到高位，避开 (版本, 序号) 唯一约束。
     *
     * @param verId 版本主键
     * @return 行数
     */
    @Update("UPDATE t_phm_dispose_step SET seq_no = seq_no + 10000 WHERE flow_ver_id = #{verId}")
    int shiftStepSeq(@Param("verId") Long verId);

    /**
     * @param id    步骤主键
     * @param seqNo 新序号
     * @return 行数
     */
    @Update("UPDATE t_phm_dispose_step SET seq_no = #{seqNo} WHERE id = #{id}")
    int setStepSeq(@Param("id") Long id, @Param("seqNo") int seqNo);
}
