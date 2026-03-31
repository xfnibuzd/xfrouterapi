/*
  ProviderIcon — renders provider-specific brand icons by delegating to @lobehub/icons when available.
  Fall back to a simple colored circle (matching historical styles) whenever the requested icon cannot be resolved.
*/
import React from 'react';
import { Avatar } from '@douyinfe/semi-ui';

import Ai360 from '@lobehub/icons/es/Ai360/index.js';
import AzureAI from '@lobehub/icons/es/AzureAI/index.js';
import Claude from '@lobehub/icons/es/Claude/index.js';
import Cloudflare from '@lobehub/icons/es/Cloudflare/index.js';
import Cohere from '@lobehub/icons/es/Cohere/index.js';
import Coze from '@lobehub/icons/es/Coze/index.js';
import DeepSeek from '@lobehub/icons/es/DeepSeek/index.js';
import Dify from '@lobehub/icons/es/Dify/index.js';
import Doubao from '@lobehub/icons/es/Doubao/index.js';
import FastGPT from '@lobehub/icons/es/FastGPT/index.js';
import Gemini from '@lobehub/icons/es/Gemini/index.js';
import Grok from '@lobehub/icons/es/Grok/index.js';
import Hunyuan from '@lobehub/icons/es/Hunyuan/index.js';
import Jimeng from '@lobehub/icons/es/Jimeng/index.js';
import Jina from '@lobehub/icons/es/Jina/index.js';
import Kling from '@lobehub/icons/es/Kling/index.js';
import LobeChat from '@lobehub/icons/es/OpenAI/index.js';
import Midjourney from '@lobehub/icons/es/Midjourney/index.js';
import Minimax from '@lobehub/icons/es/Minimax/index.js';
import Moonshot from '@lobehub/icons/es/Moonshot/index.js';
import OpenRouter from '@lobehub/icons/es/OpenRouter/index.js';
import Perplexity from '@lobehub/icons/es/Perplexity/index.js';
import Qwen from '@lobehub/icons/es/Qwen/index.js';
import Qingyan from '@lobehub/icons/es/Qingyan/index.js';
import Replicate from '@lobehub/icons/es/Replicate/index.js';
import SiliconCloud from '@lobehub/icons/es/SiliconCloud/index.js';
import Spark from '@lobehub/icons/es/Spark/index.js';
import Suno from '@lobehub/icons/es/Suno/index.js';
import Volcengine from '@lobehub/icons/es/Volcengine/index.js';
import Wenxin from '@lobehub/icons/es/Wenxin/index.js';
import XAI from '@lobehub/icons/es/XAI/index.js';
import Yi from '@lobehub/icons/es/Yi/index.js';
import Zhipu from '@lobehub/icons/es/Zhipu/index.js';

const PROVIDER_STYLES = {
  OpenAI:       { bg: '#10a37f', label: 'AI' },
  Claude:       { bg: '#d97757', label: 'C' },
  Gemini:       { bg: '#4285f4', label: 'G' },
  Moonshot:     { bg: '#000000', label: 'M' },
  Zhipu:        { bg: '#3d5afe', label: '智' },
  Qwen:         { bg: '#6236ff', label: '千' },
  DeepSeek:     { bg: '#0066ff', label: 'DS' },
  Minimax:      { bg: '#ff6b35', label: 'MM' },
  Wenxin:       { bg: '#2932e1', label: '文' },
  Spark:        { bg: '#0070f3', label: '星' },
  Midjourney:   { bg: '#000000', label: 'MJ' },
  Hunyuan:      { bg: '#006eff', label: '混' },
  Cohere:       { bg: '#39594d', label: 'Co' },
  Cloudflare:   { bg: '#f48120', label: 'CF' },
  Ai360:        { bg: '#00b051', label: '360' },
  Yi:           { bg: '#354259', label: '01' },
  Jina:         { bg: '#ff6600', label: 'J' },
  Mistral:      { bg: '#ff7000', label: 'Mi' },
  XAI:          { bg: '#000000', label: 'X' },
  Ollama:       { bg: '#ffffff', label: '🦙', textColor: '#000' },
  Doubao:       { bg: '#1a6dff', label: '豆' },
  Suno:         { bg: '#000000', label: '♪' },
  Xinference:   { bg: '#1e88e5', label: 'Xi' },
  OpenRouter:   { bg: '#6366f1', label: 'OR' },
  Dify:         { bg: '#1677ff', label: 'Di' },
  Coze:         { bg: '#4e46e5', label: 'Cz' },
  SiliconCloud: { bg: '#6c5ce7', label: 'Si' },
  FastGPT:      { bg: '#3370ff', label: 'FG' },
  Kling:        { bg: '#ff4d6a', label: '可' },
  Jimeng:       { bg: '#ff6a00', label: '即' },
  Perplexity:   { bg: '#20808d', label: 'Pp' },
  Replicate:    { bg: '#000000', label: 'Re' },
  Volcengine:   { bg: '#3370ff', label: '火' },
  Qingyan:      { bg: '#6236ff', label: '清' },
  Grok:         { bg: '#000000', label: 'Gk' },
  AzureAI:      { bg: '#0078d4', label: 'Az' },
};

const PROVIDER_ICONS = {
  OpenAI: LobeChat,
  Claude,
  Gemini,
  Moonshot,
  Zhipu,
  Qwen,
  DeepSeek,
  Minimax,
  Wenxin,
  Spark,
  Midjourney,
  Hunyuan,
  Cohere,
  Cloudflare,
  Ai360,
  Yi,
  Jina,
  XAI,
  Doubao,
  Suno,
  OpenRouter,
  Dify,
  Coze,
  SiliconCloud,
  FastGPT,
  Kling,
  Jimeng,
  Perplexity,
  Replicate,
  Volcengine,
  Qingyan,
  Grok,
  AzureAI,
};

const parseIconDescriptor = (iconName = '') => {
  if (!iconName) return {};
  const segments = iconName.split('.').map((s) => s.trim()).filter(Boolean);
  const [base = ''] = segments;
  let variant = '';
  let propSegments = segments.slice(1);

  if (propSegments.length > 0 && !propSegments[0].includes('=')) {
    variant = propSegments[0];
    propSegments = propSegments.slice(1);
  }

  const props = {};
  for (const seg of propSegments) {
    if (!seg) continue;
    const eq = seg.indexOf('=');
    if (eq === -1) {
      props[seg.trim()] = true;
      continue;
    }
    const key = seg.slice(0, eq).trim();
    const raw = seg.slice(eq + 1).trim();
    let value = raw;
    if (value.startsWith('{') && value.endsWith('}')) {
      value = value.slice(1, -1).trim();
    }
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    if (value === 'true') value = true;
    else if (value === 'false') value = false;
    else if (/^-?\d+(\.\d+)?$/.test(value)) value = Number(value);
    props[key] = value;
  }

  return { baseName: base, variant, props };
};

const normalizeSize = (value, fallback) => {
  if (typeof value === 'number') return value;
  if (typeof value === 'string' && /^\d+(\.\d+)?$/.test(value)) {
    return Number(value);
  }
  return fallback;
};

const fallbackAvatar = (style, size) => {
  const dim = normalizeSize(size, 14);
  const fontSize = Math.max(Math.round(dim * 0.45), 8);
  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        width: dim,
        height: dim,
        borderRadius: '50%',
        backgroundColor: style.bg,
        color: style.textColor || '#fff',
        fontSize,
        fontWeight: 600,
        lineHeight: 1,
        flexShrink: 0,
        userSelect: 'none',
      }}
    >
      {style.label}
    </span>
  );
};

const resolveIconComponent = (baseName, variant) => {
  const baseKey = baseName.trim();
  if (!baseKey) return null;
  const provider = PROVIDER_ICONS[baseKey];
  if (!provider) return null;
  if (variant && provider[variant]) {
    return provider[variant];
  }
  return provider;
};

export function ProviderIcon({ name, size = 14 }) {
  const descriptor = parseIconDescriptor(name);
  const style =
    PROVIDER_STYLES[descriptor.baseName] || {
      bg: '#888',
      label: descriptor.baseName ? descriptor.baseName.charAt(0).toUpperCase() : '?',
    };
  const props = { ...descriptor.props };
  if (props.size == null) props.size = size;

  const IconComponent = resolveIconComponent(descriptor.baseName, descriptor.variant);
  if (IconComponent) {
    return <IconComponent {...props} />;
  }

  return fallbackAvatar(style, props.size);
}

export function getProviderIconByName(iconName, size = 14) {
  return <ProviderIcon name={iconName} size={size} />;
}

export default ProviderIcon;
