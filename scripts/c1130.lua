--吉川ともこ
--①：自分フィールド上に「ゆるゆり」キャラクターが表側表示で存在する場合、このカードは手札から特殊召喚する事ができる。

function c1130.initial_effect(c)

	-- special summon
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1130, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1130.e1condition)
	c:RegisterEffect(e1)

end

-- ゆるゆりキャラフィルター
function c1130.e1spfilter(c)
	-- 表側表示(=IsFaceup)かつゆるゆりキャラ(=0x186A0)か
	return c:IsFaceup() and c:IsSetCard(0x186A0)
end

function c1130.e1condition(e, c)
	if c == nil then return true end
	return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0 and
		Duel.IsExistingMatchingCard(c1130.e1spfilter, c:GetControler(), LOCATION_ONFIELD, 0, 1, nil)
end

