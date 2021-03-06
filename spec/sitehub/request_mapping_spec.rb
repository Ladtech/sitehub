require 'sitehub/request_mapping'

class SiteHub
  describe RequestMapping do
    let(:mapped_url) { 'http://downstream_url' }

    subject do
      described_class.new(source_url: 'http://upstream.com/articles/123',
                          mapped_url: mapped_url,
                          mapped_path: %r{/articles/(.*)})
    end

    describe '#initialize' do
      it 'duplicates the mapped url as we mutate it' do
        expect(subject.mapped_url).to eq(mapped_url)
        expect(subject.mapped_url).to_not be(mapped_url)
      end
    end

    describe '#computed_uri' do
      it_behaves_like 'a memoized helper'

      context 'mapped_path is a regexp' do
        subject do
          described_class.new(source_url: 'http://upstream.com/articles/123',
                              mapped_url: 'http://downstream_url/$1/view',
                              mapped_path: %r{/articles/(.*)})
        end
        it 'returns the computed uri' do
          expect(subject.computed_uri).to eq(URI('http://downstream_url/123/view'))
        end
      end

      context 'mapped_path is a string' do
        subject do
          described_class.new(source_url: 'http://upstream.com/articles',
                              mapped_url: 'http://downstream_url/articles',
                              mapped_path: '/articles')
        end

        it 'returns the mapped url' do
          expect(subject.computed_uri).to eq(URI('http://downstream_url/articles'))
        end
      end

      context 'when there is a query string on the source url' do
        subject do
          described_class.new(source_url: 'http://upstream.com/articles?param=value',
                              mapped_url: 'http://downstream_url/$1',
                              mapped_path: %r{/(.*)})
        end
        it 'keeps the querystring' do
          expect(subject.computed_uri).to eq(URI('http://downstream_url/articles?param=value'))
        end
      end
    end

    describe '#host' do
      it_behaves_like 'a memoized helper'

      it 'returns the host' do
        expect(subject.host).to eq('upstream.com')
      end
    end
  end
end
