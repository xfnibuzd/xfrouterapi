import React, { useEffect } from 'react';
import { Layout, Typography } from '@douyinfe/semi-ui';
import { useTranslation } from 'react-i18next';
import { marked } from 'marked';
import { getSystemName } from '../../helpers';

const { Content } = Layout;
const { Title } = Typography;

const Document = () => {
  const { t } = useTranslation();
  
  useEffect(() => {
    let systemName = getSystemName();
    if (systemName) {
      document.title = `${t('文档')} - ${systemName}`;
    }
  }, [t]);

  const defaultDocsContent = `
# 系统使用文档

欢迎使用本系统！这是一个统一的 AI 模型聚合与分发网关，支持将各类大语言模型跨格式转换为 OpenAI、Claude、Gemini 兼容接口。

---

## 🚀 快速开始

### 1. 获取访问令牌
1. 登录系统后进入 **控制台**
2. 点击 **令牌管理** -> **添加令牌**
3. 设置令牌名称和过期时间
4. 复制生成的令牌（请妥善保管）

### 2. API 接入
将您的应用请求地址指向本系统接口：

\`\`\`bash
# 原地址
https://api.openai.com/v1/chat/completions

# 新地址
http://your-domain.com/v1/chat/completions
\`\`\`

### 3. 请求示例
\`\`\`bash
curl -X POST http://your-domain.com/v1/chat/completions \\
  -H "Authorization: Bearer YOUR_TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
\`\`\`

---

## 🎯 核心功能

### 多模型支持
- **OpenAI 系列**：GPT-3.5、GPT-4、DALL-E、Whisper 等
- **Anthropic**：Claude 系列模型
- **Google**：Gemini、PaLM 系列
- **国产模型**：文心一言、通义千问、智谱 GLM、月之暗面等
- **开源模型**：Llama、Mistral、Ollama 等

### 统一接口
- 兼容 OpenAI API 格式
- 支持流式输出
- 自动错误重试
- 请求限流保护

### 管理功能
- **令牌管理**：创建、删除、查看使用量
- **调用日志**：实时监控 API 调用记录
- **费用统计**：查看消费明细和余额
- **渠道管理**：配置不同的模型供应商

---

## 📊 使用指南

### 控制台功能

#### 令牌管理
- **创建令牌**：为不同应用创建独立令牌
- **查看用量**：实时监控每个令牌的调用情况
- **设置限额**：为令牌设置日/月调用限制

#### 日志查看
- **调用记录**：查看所有 API 调用详情
- **错误追踪**：定位失败请求的原因
- **性能分析**：监控响应时间和成功率

#### 财务管理
- **余额查询**：查看账户余额
- **消费明细**：查看每笔费用记录
- **充值入口**：支持多种充值方式

### API 参数说明

#### 基础参数
\`\`\`json
{
  "model": "gpt-3.5-turbo",      // 模型名称
  "messages": [...],              // 对话消息
  "temperature": 0.7,             // 创造性 (0-2)
  "max_tokens": 1000,             // 最大输出长度
  "stream": false                 // 是否流式输出
}
\`\`\`

#### 高级功能
- **函数调用**：支持 Function Calling
- **多模态**：图片理解、语音识别
- **长文本**：支持上下文扩展
- **批量处理**：同时处理多个请求

---

## 🔧 配置说明

### 环境变量
\`\`\`bash
API_BASE_URL=http://your-domain.com
API_KEY=your_token_here
\`\`\`

### SDK 集成

#### Python
\`\`\`python
import openai

client = openai.OpenAI(
    base_url="http://your-domain.com/v1",
    api_key="your_token"
)

response = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=[{"role": "user", "content": "Hello!"}]
)
\`\`\`

#### Node.js
\`\`\`javascript
import OpenAI from 'openai';

const client = new OpenAI({
  baseURL: 'http://your-domain.com/v1',
  apiKey: 'your_token',
});

const response = await client.chat.completions.create({
  model: 'gpt-3.5-turbo',
  messages: [{ role: 'user', content: 'Hello!' }],
});
\`\`\`

---

## ❓ 常见问题

### Q: 如何选择合适的模型？
**A**: 
- **快速响应**：选择 GPT-3.5-turbo
- **复杂推理**：选择 GPT-4 系列
- **中文优化**：选择国产模型如通义千问
- **成本敏感**：选择开源模型

### Q: 为什么请求失败？
**A**: 
- 检查令牌是否有效
- 确认余额充足
- 验证请求格式正确
- 查看错误代码和日志

### Q: 如何提高响应速度？
**A**:
- 使用地理位置最近的节点
- 启用流式输出
- 减少 max_tokens 设置
- 选择响应更快的模型

---

## 📞 技术支持

如需技术支持，请联系：
- **系统管理员**：通过控制台反馈
- **技术文档**：查看详细 API 文档
- **社区支持**：加入用户交流群

---

*本文档会持续更新，请关注最新版本*
  `;

  const htmlContent = marked.parse(defaultDocsContent);

  return (
    <Layout>
      <Content
        style={{
          padding: '24px',
          maxWidth: '800px',
          margin: '0 auto',
          background: 'var(--semi-color-bg-0)',
          borderRadius: '16px',
          boxShadow: 'var(--semi-shadow-elevated)',
        }}
      >
        <div 
          className="markdown-body" 
          style={{ padding: '20px' }}
          dangerouslySetInnerHTML={{ __html: htmlContent }} 
        />
      </Content>
    </Layout>
  );
};

export default Document;
