/*
  ProviderIcon — lightweight replacement for @lobehub/icons.
  Renders a colored circle with the provider's abbreviation.
  Zero external dependencies (only React + Semi Avatar).
*/
import React from 'react';
import { Avatar } from '@douyinfe/semi-ui';

const PROVIDER_STYLES = {
  OpenAI:       { bg: '#10a37f', label: 'AI' },
  Claude:       { bg: '#d97757', label: 'C' },
  Gemini:       { bg: '#4285f4', label: 'G' },
  Moonshot:     { bg: '#000000', label: 'M' },
  Zhipu:        { bg: '#3d5afe', label: '智' },
  Qwen:        { bg: '#6236ff', label: '千' },
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

export function ProviderIcon({ name, size = 14 }) {
  const style = PROVIDER_STYLES[name] || {
    bg: '#888',
    label: name ? name.charAt(0).toUpperCase() : '?',
  };

  const dim = typeof size === 'number' ? size : 14;
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
}

/**
 * Dynamic icon lookup by string name — replaces getLobeHubIcon().
 * Supports "OpenAI", "Claude.Color", etc. (the .Color/.Avatar suffixes are ignored
 * since we render a uniform style).
 */
export function getProviderIconByName(iconName, size = 14) {
  if (!iconName) {
    return <Avatar size='extra-extra-small'>?</Avatar>;
  }
  const baseName = String(iconName).split('.')[0].trim();
  if (PROVIDER_STYLES[baseName]) {
    return <ProviderIcon name={baseName} size={size} />;
  }
  // Fallback: first letter avatar
  return (
    <Avatar size='extra-extra-small'>
      {baseName.charAt(0).toUpperCase()}
    </Avatar>
  );
}

export default ProviderIcon;
