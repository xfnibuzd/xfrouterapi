/*
Copyright (C) 2025 QuantumNous

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

For commercial licensing, please contact support@quantumnous.com
*/

import React, { useContext, useEffect } from 'react';
import { Button, Card, Tag } from '@douyinfe/semi-ui';
import { IconPlay } from '@douyinfe/semi-icons';
import { Link, Navigate } from 'react-router-dom';
import { UserContext } from '../../context/User';
import { getSystemName } from '../../helpers';

const featureCards = [
  {
    title: '统一接口',
    description: '一个入口对接多种主流模型，兼容现有 OpenAI 风格调用。',
  },
  {
    title: '快速接入',
    description: '替换 Base URL 即可开始使用，适合新项目和存量系统迁移。',
  },
  {
    title: '稳定部署',
    description: '支持 Docker 一键部署，适合本地、测试和生产环境。',
  },
];

const Official = () => {
  const [userState] = useContext(UserContext);
  const systemName = getSystemName() || 'HS API';

  useEffect(() => {
    document.title = `${systemName} - 官网`;
  }, [systemName]);

  if (userState?.user) {
    return <Navigate to='/console' replace />;
  }

  return (
    <div className='min-h-[calc(100vh-56px)] overflow-hidden bg-[radial-gradient(circle_at_top,_rgba(37,99,235,0.08),_transparent_35%),linear-gradient(180deg,rgba(255,255,255,0.72)_0%,rgba(255,255,255,0.96)_100%)]'>
      <div className='mx-auto flex w-full max-w-7xl flex-col gap-10 px-4 py-10 sm:px-6 lg:px-8 lg:py-16'>
        <section className='relative overflow-hidden rounded-[28px] border border-[var(--semi-color-border)] bg-white/80 p-8 shadow-[0_18px_60px_rgba(15,23,42,0.08)] backdrop-blur md:p-12 lg:p-16'>
          <div className='absolute -right-16 -top-16 h-44 w-44 rounded-full bg-blue-500/10 blur-3xl' />
          <div className='absolute -bottom-16 -left-16 h-48 w-48 rounded-full bg-cyan-500/10 blur-3xl' />

          <div className='relative z-10 max-w-3xl'>
            <Tag color='blue' size='large' className='mb-5 rounded-full px-3 py-1'>
              官方网站
            </Tag>

            <h1 className='text-4xl font-semibold tracking-tight text-[var(--semi-color-text-0)] sm:text-5xl lg:text-6xl'>
              {systemName}
            </h1>

            <p className='mt-5 max-w-2xl text-base leading-8 text-[var(--semi-color-text-1)] sm:text-lg'>
              统一的大模型接口网关，支持 OpenAI、Claude、Gemini 等主流模型接入，
              帮你快速搭建稳定、可扩展、易维护的 AI 能力中台。
            </p>

            <div className='mt-8 flex flex-col gap-4 sm:flex-row'>
              <Link to='/console'>
                <Button
                  theme='solid'
                  type='primary'
                  size='large'
                  className='!rounded-full px-8'
                  icon={<IconPlay />}
                >
                  立即开始
                </Button>
              </Link>
              <Link to='/docs'>
                <Button
                  size='large'
                  className='!rounded-full px-8 border border-[var(--semi-color-border)]'
                >
                  查看文档
                </Button>
              </Link>
            </div>

            <div className='mt-8 flex flex-wrap gap-3 text-sm text-[var(--semi-color-text-1)]'>
              <span className='rounded-full bg-[var(--semi-color-fill-0)] px-4 py-2'>OpenAI 兼容</span>
              <span className='rounded-full bg-[var(--semi-color-fill-0)] px-4 py-2'>Docker 部署</span>
              <span className='rounded-full bg-[var(--semi-color-fill-0)] px-4 py-2'>生产可用</span>
            </div>
          </div>
        </section>

        <section className='grid gap-4 md:grid-cols-3'>
          {featureCards.map((item) => (
            <Card
              key={item.title}
              className='rounded-[22px] border border-[var(--semi-color-border)] bg-white/90 shadow-[0_10px_30px_rgba(15,23,42,0.05)]'
              bodyStyle={{ padding: '24px' }}
            >
              <h3 className='text-lg font-semibold text-[var(--semi-color-text-0)]'>
                {item.title}
              </h3>
              <p className='mt-3 leading-7 text-[var(--semi-color-text-1)]'>
                {item.description}
              </p>
            </Card>
          ))}
        </section>
      </div>
    </div>
  );
};

export default Official;
