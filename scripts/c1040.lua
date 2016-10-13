--吉川ちなつ
function c1040.initial_effect(c)

	-- special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1040, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c1040.spcon)
	c:RegisterEffect(e1)

end

-- 結衣フィルター
function c1040.spfilter(c)
	-- 表側表示(=IsFaceup)かつ結衣(=1020)か
	return c:IsFaceup() and c:IsCode(1020)
end

function c1040.spcon(e, c)
	if c == nil then return true end
	return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0 and
		Duel.IsExistingMatchingCard(c1040.spfilter, c:GetControler(), LOCATION_ONFIELD, 0, 1, nil)
end
