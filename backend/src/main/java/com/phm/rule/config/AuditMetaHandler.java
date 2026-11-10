package com.phm.rule.config;

import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import com.phm.rule.common.OperatorHolder;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * 插入和更新时自动填写审计字段，调用方不用每次手写操作者和时间。
 */
@Component
public class AuditMetaHandler implements MetaObjectHandler {

    /**
     * 插入时填写创建人、创建时间、修改人和逻辑删除标记。
     *
     * @param metaObject 实体元数据
     */
    @Override
    public void insertFill(MetaObject metaObject) {
        LocalDateTime now = LocalDateTime.now();
        String who = OperatorHolder.get();
        strictInsertFill(metaObject, "createBy", String.class, who);
        strictInsertFill(metaObject, "createTime", LocalDateTime.class, now);
        strictInsertFill(metaObject, "updateBy", String.class, who);
        strictInsertFill(metaObject, "updateTime", LocalDateTime.class, now);
        strictInsertFill(metaObject, "delFlag", Integer.class, 0);
    }

    /**
     * 按实体更新时刷新修改人和修改时间。使用 UpdateWrapper 的更新需要调用方自己 set。
     *
     * @param metaObject 实体元数据
     */
    @Override
    public void updateFill(MetaObject metaObject) {
        strictUpdateFill(metaObject, "updateBy", String.class, OperatorHolder.get());
        strictUpdateFill(metaObject, "updateTime", LocalDateTime.class, LocalDateTime.now());
    }
}
